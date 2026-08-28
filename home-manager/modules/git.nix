{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  programs.git = {
    enable = true;

    # git-lfs本体のインストールとfilter設定（旧filter.lfs手書き設定の置き換え）
    lfs.enable = true;

    # 基本設定
    settings = {
      user.name = "illumination-k";
      # デフォルトのemail（コンテナ等local.nix無しの環境でcommitできるように）
      # マシン固有のemailはlocal.nixで上書きする
      user.email = lib.mkDefault "illumination.k.27@gmail.com";

      core = {
        filemode = false;
        excludesfile = "~/.gitignore_global";
        editor = "vim";
        ignorecase = false;
        quotepath = false;
      };

      color.ui = "auto";

      # alias
      alias = {
        st = "status";
        aa = "add --all";
        ps = "push";
        psh = "push origin HEAD";
        pl = "pull";
        plh = "pull origin HEAD";
        cm = "commit";
        cmm = "commit -m";
        rmb = "branch -D";
        ch = "checkout";
        sw = "switch";
        issues = "!gh issue list | cat";
        graph = "log --graph --date-order --all --pretty=format:'%h %Cred%d %Cgreen%ad %Cblue%cn %Creset%s' --date=short";
        root = "! git rev-parse --show-superproject-working-tree --show-toplevel | grep '^/'";
        aliases = "config --get-regexp alias";
        default = "! basename $(git symbolic-ref --short refs/remotes/origin/HEAD)";
        ret-default = "! git checkout $(git default) && git pull origin HEAD";
        scheckout = "! git branch -l | sk | xargs git checkout";
        wtadd = ''
          !f() { \
            branch_name="$1"; \
            worktree_path="$2"; \
            if [ -z "$branch_name" ] || [ -z "$worktree_path" ]; then \
              echo "Usage: git wtadd <branch-name> <path>"; \
              return 1; \
            fi; \
            git branch "$branch_name" main && \
            git worktree add "$worktree_path"/"$branch_name" "$branch_name" && \
            code "$worktree_path"; \
          }; f'';
      };

      github.user = "illumination-k";

      merge.conflictStyle = "zdiff3";

      # git-secrets（`git secrets --register-aws --global` 相当）
      # 検出ルールはグローバル、フックは init.templateDir 経由で
      # 新規 clone / init のリポジトリに自動で入る（既存repoは `git secrets --install`）
      secrets = {
        providers = [ "git secrets --aws-provider" ];
        patterns = [
          "(A3T[A-Z0-9]|AKIA|AGPA|AIDA|AROA|AIPA|ANPA|ANVA|ASIA)[A-Z0-9]{16}"
          "ABSK[A-Za-z0-9+/]{109,}=*"
          "bedrock-api-key-YmVkcm9jay5hbWF6b25hd3MuY29t"
          ''("|')?(AWS|aws|Aws)?_?(SECRET|secret|Secret)?_?(ACCESS|access|Access)?_?(KEY|key|Key)("|')?\s*(:|=>|=)\s*("|')?[A-Za-z0-9/\+=]{40}("|')?''
          # 12桁の数字全般に当たるため誤検出しやすい。引っかかった公開値は
          # リポジトリ側で `git config --add secrets.allowed <値>` して黙らせる
          ''("|')?(AWS|aws|Aws)?_?(ACCOUNT|account|Account)_?(ID|id|Id)?("|')?\s*(:|=>|=)\s*("|')?[0-9]{4}\-?[0-9]{4}\-?[0-9]{4}("|')?''
        ];
        allowed = [
          # AWSドキュメントのサンプル値
          "AKIAIOSFODNN7EXAMPLE"
          "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
        ];
      };

      # git-secretsのフックを新規リポジトリへ自動配置する
      init.templateDir = "${config.home.homeDirectory}/.git-templates/git-secrets";
    } // lib.optionalAttrs isLinux {
      # コンテナ（dev pod）へrootで入るとuid 1000所有のrepoが
      # "dubious ownership" 扱いになりgitが動かないため、
      # Linux（コンテナ用途）では全ディレクトリを信頼する
      safe.directory = [ "*" ];
    };

    # リポジトリ別 user 設定（personal repos でメール切替など）
    includes = [
      {
        condition = "gitdir:~/ghq/github.com/illumination-k/";
        path = "~/.gitconfig-personal";
      }
    ];

    # .gitignore_global
    ignores = [
      ".DS_Store"
      "*.swp"
      "*.swo"
      "*~"
      ".vscode/"
      ".idea/"
    ];
  };

  # delta統合
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
    };
  };

  # .gitignore_globalファイル配置
  home.file.".gitignore_global".source = ../../.gitignore_global;

  # includeIfが参照するpersonal設定（未配置だとincludeが空振りする）
  home.file.".gitconfig-personal".source = ../../.gitconfig-personal;

  # git-secretsのフックテンプレート（init.templateDirが参照する）
  # `git secrets --install` が書くものと同じ内容を宣言的に配置する
  home.file.".git-templates/git-secrets/hooks/pre-commit" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      git secrets --pre_commit_hook -- "$@"
    '';
  };
  home.file.".git-templates/git-secrets/hooks/commit-msg" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      git secrets --commit_msg_hook -- "$@"
    '';
  };
  home.file.".git-templates/git-secrets/hooks/prepare-commit-msg" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      git secrets --prepare_commit_msg_hook -- "$@"
    '';
  };
}
