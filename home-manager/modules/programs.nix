{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  home.packages = with pkgs; [
    # 開発ツール
    cmake
    gcc
    wget

    # Git関連
    gh           # GitHub CLI
    ghq          # Gitリポジトリ管理
    git-delta    # diff表示改善
    gitui        # ターミナルUI Gitクライアント

    # Rust製CLIツール
    eza          # ls代替（exaの後継）
    bat          # cat代替
    ripgrep      # grep代替
    fd           # find代替
    skim         # fzf代替（sk）

    # Rust開発環境
    cargo
    rustc

    # エディタ & ターミナル
    helix        # モダンなテキストエディタ
    zellij       # ターミナルマルチプレクサ（tmux代替）
    yazi         # ターミナルファイルマネージャー

    # 言語バージョン管理
    mise         # 統合ランタイムマネージャー（旧rtx）
    uv           # 高速なPythonパッケージマネージャー

    # シェル環境
    zsh
    starship

  ] ++ lib.optionals isDarwin [
    # macOS専用パッケージ
    coreutils    # gls, gdircolors等

  ] ++ lib.optionals isLinux [
    # Linux専用パッケージ
    xsel         # クリップボード
  ];
}
