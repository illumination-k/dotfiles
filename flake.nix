{
  description = "illumination-k's dotfiles - Nix + Home Manager";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # サポートするシステム
      systems = [ "x86_64-darwin" "aarch64-darwin" "x86_64-linux" "aarch64-linux" ];

      # システム別設定を生成
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # Home Manager設定生成関数
      mkHomeConfiguration = system: username:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          isDarwin = pkgs.stdenv.isDarwin;
          isLinux = pkgs.stdenv.isLinux;
        in
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ ./home-manager/home.nix ];
          extraSpecialArgs = {
            inherit isDarwin isLinux;
          };
        };

    in {
      # Home Manager設定
      homeConfigurations = {
        # macOS (Apple Silicon)
        "testuser@aarch64-darwin" = mkHomeConfiguration "aarch64-darwin" "testuser";

        # macOS (Intel)
        "testuser@x86_64-darwin" = mkHomeConfiguration "x86_64-darwin" "testuser";

        # Linux (x86_64)
        "testuser@x86_64-linux" = mkHomeConfiguration "x86_64-linux" "testuser";

        # Linux (ARM64) - Docker on Apple Silicon
        "testuser@aarch64-linux" = mkHomeConfiguration "aarch64-linux" "testuser";
      };

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
