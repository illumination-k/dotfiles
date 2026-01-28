{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  programs.zellij = {
    enable = true;

    # 基本設定
    settings = {
      # テーマ
      theme = "default";

      # デフォルトシェル
      default_shell = "${pkgs.zsh}/bin/zsh";

      # コピーコマンド（プラットフォーム別）
      copy_command = if isDarwin then "pbcopy"
                     else if isLinux then "xsel --clipboard --input"
                     else "cat";

      # マウス操作
      mouse_mode = true;

      # ペイン番号表示
      pane_frames = true;

      # スクロールバッファサイズ
      scroll_buffer_size = 10000;

      # 簡略化されたUI
      simplified_ui = false;

      # セッション直列化
      session_serialization = true;

      # コピーモードでvimキーバインド
      copy_on_select = false;
    };
  };

  # Zellijのテーマやレイアウトはファイルで管理する場合
  # home.file.".config/zellij/config.kdl".text = ''
  #   // カスタム設定をここに
  # '';
}
