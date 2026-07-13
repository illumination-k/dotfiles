{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  programs.git = {
    enable = true;

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

      filter.lfs = {
        required = true;
        clean = "git-lfs clean -- %f";
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
      };

      merge.conflictStyle = "zdiff3";
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
}
