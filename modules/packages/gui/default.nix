{ pkgs, ... }:

{
  environment.systemPackages = [
    # --- gaming ---
    pkgs.lutris
    pkgs.wineWowPackages.full
    pkgs.winetricks
    pkgs.protontricks
    pkgs.steam-run
    pkgs.mangohud

    # --- graphics ---
    pkgs.gimp-with-plugins
    pkgs.gmic
    pkgs.imagemagick
    pkgs.inkscape
    pkgs.krita

    # --- image/video libs ---
    pkgs.libwebp
    pkgs.libheif
    pkgs.libraw
    pkgs.openexr
    pkgs.jasper
    pkgs.libavif

    # --- vulkan ---
    pkgs.vulkan-tools
    pkgs.vulkan-loader
    pkgs.vulkan-validation-layers
  ];
}

