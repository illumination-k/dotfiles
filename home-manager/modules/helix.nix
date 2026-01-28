{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  programs.helix = {
    enable = true;

    settings = {
      # テーマ
      theme = "onedark";

      # エディタ設定
      editor = {
        line-number = "relative";
        mouse = true;
        cursorline = true;
        auto-save = false;
        completion-trigger-len = 1;
        true-color = true;
        rulers = [80 120];

        # カーソル形状
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };

        # ファイル選択
        file-picker = {
          hidden = false;
        };

        # インデント設定
        indent-guides = {
          render = true;
          character = "│";
        };

        # LSP設定
        lsp = {
          display-messages = true;
          display-inlay-hints = true;
        };

        # ステータスライン
        statusline = {
          left = ["mode" "spinner" "file-name" "file-modification-indicator"];
          center = [];
          right = ["diagnostics" "selections" "position" "file-encoding" "file-line-ending" "file-type"];
        };
      };

      # キーマップ
      keys = {
        normal = {
          # スペースキーをリーダーキーとして使う場合の例
          # space.w = ":w"; # 保存
          # space.q = ":q"; # 終了
        };
      };
    };

    # 言語サーバー設定
    languages = {
      language-server = {
        # Rust
        rust-analyzer = {
          config = {
            checkOnSave = {
              command = "clippy";
            };
          };
        };

        # Python (pyright)
        pyright = {
          command = "pyright-langserver";
          args = ["--stdio"];
        };

        # TypeScript/JavaScript
        typescript-language-server = {
          command = "typescript-language-server";
          args = ["--stdio"];
        };
      };

      language = [
        # Python設定
        {
          name = "python";
          auto-format = true;
          formatter = {
            command = "black";
            args = ["-"];
          };
        }

        # Rust設定
        {
          name = "rust";
          auto-format = true;
        }

        # Markdown設定
        {
          name = "markdown";
          auto-format = false;
        }
      ];
    };
  };
}
