# Nix + Home Manager クイックスタート

## コンテナで試す

```bash
# 1. Dockerコンテナを起動
cd ~/dotfiles
./docker/run-nix-test.sh

# 2. コンテナ内で実行
export USER=testuser
export HOME=/home/testuser
mkdir -p $HOME/.local/state/nix/profiles
cd /workspace

# 3. flake.nixの構文チェック
nix flake check

# 4. Home Managerビルド
nix build --impure .#homeConfigurations."testuser@aarch64-linux".activationPackage

# 5. Home Manager適用
nix run --impure home-manager/master -- switch --impure --flake .#testuser@aarch64-linux
```

## ローカル環境で使う（本番）

### 1. Nixのインストール

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Home Managerの適用

```bash
cd ~/dotfiles

# local.nixを作成（メールアドレス等を設定）
cp home-manager/modules/local.nix.template home-manager/modules/local.nix
vim home-manager/modules/local.nix

# .gitignoreに追加
echo "home-manager/modules/local.nix" >> .gitignore

# home.nixでlocal.nixをインポート（コメント解除）
# imports = [ ./modules/local.nix ];

# 適用
home-manager switch --impure --flake .#"$(whoami)@$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')"
```

### 3. パッケージモジュールを有効化

[home-manager/home.nix](home-manager/home.nix)の`imports`セクションで、必要なモジュールをコメント解除：

```nix
imports = [
  ./modules/programs.nix  # パッケージ管理
  ./modules/shell.nix     # zsh設定
  ./modules/git.nix       # git設定
  ./modules/tmux.nix      # tmux設定
  ./modules/local.nix     # マシン固有設定
];
```

### 4. 更新

```bash
# flakeの依存を更新
nix flake update

# 再度適用
home-manager switch --impure --flake .
```

## 管理対象パッケージ

- **開発ツール**: cmake, gcc, wget
- **Git関連**: gh, ghq, git-delta
- **Rust CLIツール**: eza, bat, ripgrep, fd, skim
- **Rust環境**: cargo, rustc, cargo-make
- **Python**: pyenv, pipenv
- **Node.js**: nodejs_20
- **シェル**: zsh, tmux, starship

詳細は [home-manager/modules/programs.nix](home-manager/modules/programs.nix) を参照。

## トラブルシューティング

### ビルドエラー

```bash
# 詳細なトレースを表示
nix build --show-trace .#homeConfigurations."$(whoami)@$(uname -m)-$(uname -s | tr '[:upper:]' '[:lower:]')".activationPackage
```

### ロールバック

```bash
# 過去の世代を確認
home-manager generations

# ロールバック
home-manager switch --rollback
```

### クリーンビルド

```bash
# Nixストアをクリーンアップ
nix-collect-garbage -d

# 再ビルド
home-manager switch --impure --flake .
```
