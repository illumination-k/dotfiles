{ config, pkgs, lib, isDarwin, isLinux, ... }:

let
  # プラットフォーム変数
  platform = if isDarwin then "osx" else if isLinux then "linux" else "unknown";

in {
  programs.zsh = {
    enable = true;

    # .zshenv相当
    envExtra = ''
      # パフォーマンス測定用（必要に応じてコメント解除）
      # zmodload zsh/zprof && zprof
    '';

    # .zshrc相当（既存モジュールを統合）
    initContent = ''
      # ===== dircolors =====
      ${lib.optionalString isDarwin ''
        if [ -f ~/.colorrc ]; then
          eval $(${pkgs.coreutils}/bin/gdircolors ~/.colorrc)
        fi
      ''}
      ${lib.optionalString isLinux ''
        if [ -f ~/.colorrc ]; then
          eval $(dircolors ~/.colorrc)
        fi
      ''}

      # ===== 10_utils.zsh =====
      # プラットフォーム検出
      export PLATFORM="${platform}"

      # has_cmd: コマンド存在確認
      has_cmd() {
          type $1 >/dev/null 2>&1
      }

      # fuzzy_search: ファジーファインダー
      fuzzy_search() {
          if has_cmd sk; then
              sk
          elif has_cmd fzf; then
              fzf
          elif has_cmd peco; then
              peco
          else
              echo "Neither sk, fzf, nor peco are installed!"
              exit 1
          fi
      }

      # ===== 20_keybind.zsh =====
      ${builtins.readFile ../../.zsh/20_keybind.zsh}

      # ===== 50_setopt.zsh =====
      ${builtins.readFile ../../.zsh/50_setopt.zsh}

      # ===== 60_misc.zsh =====
      ${builtins.readFile ../../.zsh/60_misc.zsh}

      # ===== 80_functions.zsh =====
      ${builtins.readFile ../../.zsh/80_functions.zsh}

      # zshrc コンパイル
      if [ ! -f ~/.zshrc.zwc ] || [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
          zcompile ~/.zshrc
      fi

      # ローカルプロファイル読み込み
      if [ -f ~/.local_profile ]; then
          source ~/.local_profile
      fi

      # リポジトリ固有設定
      if [ -d ./.git ]; then
          if [ -f $(git root)/.reporc ]; then
              source $(git root)/.reporc
          fi
      fi

      # ===== mise activation =====
      if has_cmd mise; then
          eval "$(mise activate zsh)"
      fi

      # ===== uv completion =====
      if has_cmd uv; then
          eval "$(uv generate-shell-completion zsh)"
      fi
    '';

    # ===== 30_alias.zsh =====
    shellAliases = {
      # ls（ezaまたはplatform依存）
      ls = if (builtins.hasAttr "eza" pkgs) then "eza -F"
           else if isDarwin then "gls -F --color=auto"
           else "ls -F --color=auto";
      lsa = if (builtins.hasAttr "eza" pkgs) then "eza -aF"
            else if isDarwin then "gls -aF --color=auto"
            else "ls -aF --color=auto";
      tree = "eza -hTF --ignore-glob='.git'";

      # cd shortcuts
      ".." = "cd ..";
      "..2" = "cd ../..";
      "..3" = "cd ../../..";
      h = "cd ~";
      dotf = "cd ~/dotfiles";

      # docker
      d = "docker";

      # git
      g = "git";
      gg = "gitui";  # Git TUI

      # ghq
      gcd = "cd $(ghq list -p | fuzzy_search)";
      gcode = "code $(ghq list -p | fuzzy_search)";
      ghrw = "gh repo view -w $(ghq list | fuzzy_search)";

      # grep
      grep = if (builtins.hasAttr "ripgrep" pkgs) then "rg" else "grep --color";

      # エディタ
      hx = "helix";
      vim = "helix";  # vimコマンドをhelixに置き換え

      # ターミナルマルチプレクサ
      zj = "zellij";

      # Python/uv
      py = "python3";
      venv = "uv venv";
      pip = "uv pip";

      # mise
      m = "mise";

      # zshrc管理
      zshrc = "helix ~/.zshrc";
      reload = "source ~/.zshrc";

      # クリップボード（platform依存）
      c = if isDarwin then "pbcopy"
          else "xsel --clipboard --input";
      getpwd = "pwd | c";
    };

    # zsh plugins（zinitの代替）
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-syntax-highlighting";
          rev = "0.7.1";
          sha256 = "sha256-gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
        };
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-autosuggestions";
          rev = "v0.7.0";
          sha256 = "sha256-KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
        };
      }
      {
        name = "zsh-completions";
        src = pkgs.fetchFromGitHub {
          owner = "zsh-users";
          repo = "zsh-completions";
          rev = "0.34.0";
          sha256 = "sha256-qSobM4PRXjfsvoXY6ENqJGI9NEAaFFzlij6MPeTfT0o=";
        };
      }
    ];

    # zsh機能有効化
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Starship（プロンプト）
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  # 設定ファイルの配置
  home.file.".starship.toml".source = ../../.starship.toml;
  home.file.".colorrc".source = ../../.colorrc;

}
