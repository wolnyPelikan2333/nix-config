{
  description = "Konfiguracja Systemu Michała - Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Dodajemy oficjalne źródło Home-Managera dla wersji unstable
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, home-manager, emacs-overlay, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Moduł dla emacs-overlay
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ (import emacs-overlay) ];
        })
        
        ./configuration.nix

        # Wpinamy Home-Managera do systemu jako moduł NixOS
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          
          # Wskazujemy plik konfiguracyjny dla Twojego użytkownika
          home-manager.users.michal = import ./home/michal.nix;
        }
      ];
    };
  };
}
