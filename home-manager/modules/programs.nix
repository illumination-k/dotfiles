{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  home.packages = with pkgs; [
    # 開発ツール
    cmake
    gnumake      # make（cmakeのビルドに必須）
    gcc
    pkg-config   # native依存クレート（openssl-sys等）のビルドに必要
    openssl

    # ネットワーク
    curl         # 各種スクリプト・インストーラの前提

    # JSON/YAML
    jq           # 互換用（ghやスクリプトがjq前提のことが多い）

    # Git関連
    gh           # GitHub CLI
    ghq          # Gitリポジトリ管理
    hunk         # agent向け変更セットのターミナルdiffビューア
    git-secrets  # コミット前にsecretの混入を検出するgitフック

    # Rust製CLIツール
    eza          # ls代替（exaの後継）
    bat          # cat代替
    ripgrep      # grep代替
    fd           # find代替
    skim         # fzf代替（sk）
    sd           # sed代替
    dust         # du代替
    bottom       # top/htop代替（btm）
    procs        # ps代替
    hwatch       # watch代替
    hyperfine    # ベンチマーク
    tokei        # コード行数カウント
    ouch         # 圧縮/展開の統一CLI（tar/zip/zstd等を自動判別）

    # Rust開発環境
    cargo
    rustc
    rust-analyzer # Rust LSP

    # LSP/フォーマッタ（helix用）
    nil          # Nix LSP（Rust製）
    taplo        # TOML LSP + フォーマッタ（Rust製）
    yaml-language-server # YAML LSP（k8sマニフェスト用）

    # エディタ & ターミナル
    helix        # モダンなテキストエディタ
    yazi         # ターミナルファイルマネージャー

    # 言語バージョン管理
    mise         # 統合ランタイムマネージャー（旧rtx）
    uv           # 高速なPythonパッケージマネージャー

    # Kubernetes
    kubectl      # Kubernetes CLI

    # 認証
    entra-helper # Entra IDのaccess tokenを発行するCLI（overlay経由・自作）

    # シェル環境
    zsh
    starship

  ] ++ lib.optionals isDarwin [
    # macOS専用パッケージ
    coreutils    # gls, gdircolors等

  ] ++ lib.optionals isLinux [
    # Linux専用パッケージ
    coreutils    # mv, mkdir, dirname等
    findutils    # find, xargs等
    gnugrep      # grep
    gnused       # sed
    gawk         # awk（goawk等の間借りだとリンク切れしうるため明示的に持つ）
    diffutils    # diff, cmp（他パッケージのstoreパス依存だとGCで消えうる）
    getent       # getent
    xsel         # クリップボード
    libsecret    # secret-tool CLI + libsecret-1.so（GCで消えないようprofileに固定）
    dbus         # dbus-daemon（Secret Serviceのセッションバス。headless podでは起動スクリプトが立てる）
    gnome-keyring # gnome-keyring-daemon（libsecretのSecret Service実装）
    openssh      # dev pod用sshd（ssh/sftp/ssh-keygen含む）
    bashInteractive # bash前提のスクリプト用（最小コンテナにはbashが無い）

    # コンテナ最小環境で欠けがちな基盤ツール
    # （coreutilsにtarは含まれない。miseのランタイム展開等に必須）
    gnutar
    gzip
    xz
    zstd
    unzip
    less         # pager（git log / kubectl explain等が前提）
    procps       # ps, top, free等
    rsync
  ];
}
