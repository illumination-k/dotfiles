{ config, pkgs, lib, isDarwin, isLinux, codex, system, ... }:

let
  # claude-code: nixpkgs版が下記バージョンより古い場合は公式リリースの
  # ネイティブバイナリへフォールバックする（docker/images.nixのherdrと
  # 同じパターン。flake updateでnixpkgsが追いつけば自動でnixpkgs版になる）。
  # 更新時は https://downloads.claude.ai/claude-code-releases/<ver>/manifest.json
  # からversionと各platformのchecksumを転記する
  claudeMinVersion = "2.1.220";
  claudeChecksums = {
    "darwin-arm64" = "8addc857f3fe64d5a0368af9ee50321b50afb4a6918ba3ef018ab84f5dbbe081";
    "darwin-x64" = "dca7be0aa7d3d924836d440e0c6d8e3d47ef3c8e61fa5809b54b9017170ce2f3";
    "linux-arm64" = "159e4a51d796f3bf14677577100f7efb845611b1ceaf0c30cbd8d4650d942185";
    "linux-x64" = "674f61f20ff306f3100cf9200e4c36c4b70278b5bef2884549819b942a89c863";
  };
  claudePlatformKey =
    "${pkgs.stdenvNoCC.hostPlatform.node.platform}-${pkgs.stdenvNoCC.hostPlatform.node.arch}";
  claudeCode =
    if lib.versionAtLeast pkgs.claude-code.version claudeMinVersion
    then pkgs.claude-code
    else pkgs.claude-code.overrideAttrs (old: {
      version = claudeMinVersion;
      src = pkgs.fetchurl {
        url = "https://downloads.claude.ai/claude-code-releases/${claudeMinVersion}/${claudePlatformKey}/claude";
        sha256 = claudeChecksums.${claudePlatformKey};
      };
    });
in
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
    claudeCode  # Anthropic Claude Code CLI（claudeMinVersionフォールバック付き）
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
    ./modules/claude.nix     # Claude Codeグローバルメモリ
  ];
}
