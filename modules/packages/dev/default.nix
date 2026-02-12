{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- Neovim support ---
    nil                             # Nix LSP
    alejandra                       # Nix formatter

    nodePackages.typescript         # JS / TS
    nodePackages.typescript-language-server
    nodePackages.prettier           # JS formatter
  ];
}

