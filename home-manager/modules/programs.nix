{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  home.packages = with pkgs; [
    # 開発ツール
    cmake
    gnumake      # make（cmakeのビルドに必須）
    gcc
    just         # Rust製タスクランナー（Makefile代替）
    pkg-config   # native依存クレート（openssl-sys等）のビルドに必要
    openssl

    # ネットワーク
    curl         # 各種スクリプト・インストーラの前提
    xh           # Rust製HTTPクライアント（HTTPie互換）

    # JSON/YAML
    jaq          # Rust製jqクローン
    jq           # 互換用（ghやスクリプトがjq前提のことが多い）
    yq-go        # YAML処理（k8sマニフェスト用）

    # Git関連
    gh           # GitHub CLI
    ghq          # Gitリポジトリ管理
    delta        # diff表示改善 (git-delta)
    gitui        # ターミナルUI Gitクライアント
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
    zellij       # ターミナルマルチプレクサ（tmux代替）
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

  # direnv（nix-direnv統合）
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # zoxide（Rust製のスマートcd）
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
