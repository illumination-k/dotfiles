# claude-dev: K8s上のinteractive Claude Code dev pod

dotfiles（Nix + Home Manager）ベースのイメージで、K8s上に長寿命のinteractive開発環境を立てる構成。

- **herdr**（agent-awareなターミナルマルチプレクサ）と **claude-code** はHome Manager経由でイメージに焼き込み済み
- **StatefulSet + PVC** で `/workspace` と `~/.claude`（セッション履歴・認証）を永続化。Podが再スケジュールされても `claude --resume` で復元できる
- Pod内に **sshd** が常駐し、`kubectl port-forward` 経由のssh接続（Zed Remote Development含む）に対応

## イメージのビルド

イメージはDockerfileではなくnix（`dockerTools.streamLayeredImage`、定義は `docker/images.nix`）でビルドする。

```bash
# dev pod用イメージ（要nix。無ければ ./docker/run-ci.sh --dev がnixos/nixコンテナ経由でビルドする）
nix build .#docker-dev && ./result | docker load
docker tag devenv-dev:latest ghcr.io/illumination-k/devenv-dev:latest
docker push ghcr.io/illumination-k/devenv-dev:latest
```

masterへのpushでは GitHub Actions（docker-ci.yml）が `devenv`（runtime）と `devenv-dev`（dev）の両方をGHCRへpushする。

> **Note**: GHCRの新規パッケージはデフォルトでprivateになる。クラスタから
> pullできない場合は、パッケージをpublicにするか`imagePullSecrets`を設定すること。

## デプロイ

```bash
# Secret（APIキーとssh公開鍵）
kubectl create secret generic claude-dev \
  --from-literal=anthropic-api-key="sk-ant-..." \
  --from-file=authorized-keys="$HOME/.ssh/id_ed25519.pub"

kubectl apply -k k8s/claude-dev
kubectl rollout status statefulset/claude-dev
```

APIキーの代わりにOAuthを使う場合はSecretの`anthropic-api-key`を省略し、初回接続時にpod内で`claude login`する。認証情報は`CLAUDE_CONFIG_DIR=~/.claude`（PVC）に永続化される。

## 接続

### kubectl exec（手軽）

```bash
# イメージにはsuが無いため、専用のdev-loginヘルパーでユーザーのログインシェルに入る
kubectl exec -it claude-dev-0 -- /usr/local/bin/dev-login
# pod内で
herdr        # attach。切断してもherdr serverとagentは生き続ける
```

`kubectl exec`の切断ではPod内のherdr serverは死なないので、再接続して`herdr`すれば元のワークスペースに戻れる。

### ssh経由（TTY忠実度が高い・Zed Remote用）

```bash
kubectl port-forward pod/claude-dev-0 2222:22 &
ssh -p 2222 illumination-k@127.0.0.1
```

`~/.ssh/config`に書いておくと楽:

```
Host claude-dev
  HostName 127.0.0.1
  Port 2222
  User illumination-k
```

ZedのRemote Development（SSH）で`claude-dev`を指定すれば、エディタはZed・ターミナルパネルで`herdr` attachという構成になる。

sshホストキーは`/data/ssh`（PVCの`ssh-host-keys` subPath）に永続化されるため、Pod再作成後もknown_hostsの警告は出ない。

## 環境変数の伝搬

sshdはコンテナのenvをセッションに引き継がないため、entrypointが起動時に
`ANTHROPIC_API_KEY`等のホワイトリスト（`DEV_POD_EXPORT_VARS`で上書き可）を
`~/.ssh/environment`（600、ユーザーのみ読める）へ書き出している。
`kubectl exec`（`dev-login`含む）の場合はコンテナenvがそのまま継承される。

## レイアウト

| パス | 実体 | 用途 |
|---|---|---|
| `/workspace` | PVC subPath `workspace` | リポジトリ・作業ディレクトリ |
| `~/.claude` | PVC subPath `claude-config` | Claude Codeのセッション・認証（`CLAUDE_CONFIG_DIR`） |
| `/data/ssh` | PVC subPath `ssh-host-keys` | sshホストキー |
| `~/` それ以外 | イメージ焼き込み | Home Manager activation済みdotfiles |
