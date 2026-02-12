{
  description = "NixOS + Home-Manager configuration for desktop";

  inputs = {
    # Stabilne źródło pakietów dla NixOS 25.05
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager – wersja kompatybilna z NixOS 25.05
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      # -----------------------------
      #       NIXOS CONFIG
      # -----------------------------
      nixosConfigurations.desktop = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs; };

        modules = [
          # Główny plik systemu
          ./nixos/configuration.nix

          # Moduł Home Managera (konieczny)
          home-manager.nixosModules.home-manager

          # -----------------------------
          # HOME MANAGER – użytkownik michal
          # -----------------------------
          ({
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.michal = import ./home/michal.nix;
          })

          # -----------------------------
          # NH z nixpkgs — jako osobny moduł
          # -----------------------------
          ({ config, pkgs, ... }: {
            environment.systemPackages = [
              pkgs.nh
            ];
          })
        ];
      };

      # -----------------------------
      # Wymagane przez NH / flakes
      # -----------------------------
      packages.${system}.default =
        self.nixosConfigurations.desktop.config.system.build.toplevel;
    };
}

# backup utworzony
