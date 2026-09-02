{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  # Claude Code のグローバルメモリ。
  # 環境に入っているRust製CLIの存在をagentへ伝え、標準コマンドより
  # 優先して使わせる（~/.claude/ 自体はagentが書き込むのでファイル単位で配置する）。
  home.file.".claude/CLAUDE.md".source = ../files/claude/CLAUDE.md;
}
