{
  description = "Konfiguracja Systemu Michała - Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Dodajemy źródło dla nowszego Emacsa
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };

  outputs = { self, nixpkgs, emacs-overlay, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # Ten moduł sprawia, że emacs-unstable będzie dostępny w Twoim systemie
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ (import emacs-overlay) ];
        })
        ./nixos/configuration.nix
      ];
    };
  };
}
