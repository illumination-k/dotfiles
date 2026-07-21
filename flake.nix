{
  description = "illumination-k's dotfiles - Nix + Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    entra-helper = {
      url = "github:illumination-k/entra-helper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, codex, entra-helper, ... }:
    let
      # サポートするシステム
      # （x86_64-darwinはnixpkgs 26.11でサポート打ち切りのため除外）
      systems = [ "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];

      # システム別設定を生成
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Home Manager設定生成関数
      mkHomeConfiguration = system: username:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ entra-helper.overlays.default ];
          };
          isDarwin = pkgs.stdenv.isDarwin;
          isLinux = pkgs.stdenv.isLinux;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home-manager/home.nix ];
          extraSpecialArgs = {
            inherit isDarwin isLinux;
            inherit codex;
            system = system;
          };
        };

    in {
      # Home Manager設定
      homeConfigurations = {
        # macOS (Apple Silicon)
        "illumination-k@aarch64-darwin" = mkHomeConfiguration "aarch64-darwin" "illumination-k";

        # Linux (x86_64)
        "illumination-k@x86_64-linux" = mkHomeConfiguration "x86_64-linux" "illumination-k";

        # Linux (ARM64) - Docker on Apple Silicon
        "illumination-k@aarch64-linux" = mkHomeConfiguration "aarch64-linux" "illumination-k";
      };

      # Dockerイメージ（Linuxのみ）:
      #   nix build .#docker-runtime && ./result | docker load
      #   nix build .#docker-dev && ./result | docker load
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
        import ./docker/images.nix {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
            overlays = [ entra-helper.overlays.default ];
          };
          homeConfiguration = self.homeConfigurations."illumination-k@${system}";
        });

      # 開発環境（コンテナ内で使用）
      devShells = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              git
              vim
            ];
          };
        }
      );
    };
}
