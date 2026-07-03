{ config, pkgs, lib, isDarwin, isLinux, codex, herdr, system, ... }:

{
  # Home Managerバージョン
  home.stateVersion = "23.11";

  # ユーザー情報（環境変数から取得、空ならデフォルト）
  home.username = let user = builtins.getEnv "USER"; in
    if user != "" then user else "illumination-k";
  home.homeDirectory = let home = builtins.getEnv "HOME"; in
    if home != "" then home else "/home/illumination-k";

  # Home Manager自身の管理を有効化
  programs.home-manager.enable = true;

  # テスト用の最小パッケージ
  home.packages = with pkgs; [
    hello  # 動作確認用
    codex.packages.${system}.codex  # OpenAI Codex CLI (Rust版)
    claude-code  # Anthropic Claude Code CLI
    herdr.packages.${system}.default  # agent-aware terminal multiplexer
  ];

  # 環境変数
  home.sessionVariables = {
    NIX_MANAGED = "true";
  };

  # モジュールのインポート
  imports = [
    ./modules/programs.nix   # パッケージ管理
    ./modules/shell.nix      # zsh設定
    ./modules/git.nix        # git設定
    ./modules/helix.nix      # Helixエディタ設定
    ./modules/zellij.nix     # Zellijターミナル設定
  ];
}
