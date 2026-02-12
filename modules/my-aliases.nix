{ config, lib, ... }:

{
  options.my.aliases.enable =
    lib.mkEnableOption "Enable custom aliases";

  config = lib.mkIf config.my.aliases.enable {

    programs.zsh.shellAliases = lib.mkMerge [
      {
        ll = "eza -la";
        gs = "git status";
      }
    ];

    programs.zsh.initContent = lib.mkMerge [
      ''
        # yazi — cd after exit
        y() {
          local tmp="$(mktemp -t yazi-cwd.XXXXXX)"
          yazi --cwd-file="$tmp"
          if [ -f "$tmp" ]; then
            local dir="$(cat "$tmp")"
            rm -f "$tmp"
            [ -d "$dir" ] && cd "$dir"
          fi
        }
      ''
    ];

  };
}

