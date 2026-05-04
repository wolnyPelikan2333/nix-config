{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # --- Neovim support ---
    nil # Nix LSP
    alejandra # Nix formatter

    typescript # JS / TS
    typescript-language-server
    prettier # JS formatter
  ];
}
