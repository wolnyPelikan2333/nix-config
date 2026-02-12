{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # --- core ---
    neovim
    btop
    fastfetch
    wezterm
    copyq

    # --- CLI tools ---
    binutils
    ripgrep
    fd
    tree
    jq
    mpv
    mpd
    mpc
    yt-dlp
    (pkgs.writeShellScriptBin "nss" ''
      exec /etc/nixos/scripts/nss-safe "$@"
    '')
  ];
}

