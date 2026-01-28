{ config, pkgs, lib, isDarwin, isLinux, ... }:

{
  programs.git = {
    enable = true;

    # ユーザー情報
    userName = "illumination-k";

    # 基本設定
    extraConfig = {
      core = {
        filemode = false;
        excludesfile = "~/.gitignore_global";
        editor = "vim";
        ignorecase = false;
        quotepath = false;
      };

      color.ui = "auto";

      # alias（.gitconfig_globalより）
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

    # git-delta統合
    delta = {
      enable = true;
      options = {
        navigate = true;
      };
    };

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

  # .gitignore_globalファイル配置
  home.file.".gitignore_global".source = ../../.gitignore_global;
}
