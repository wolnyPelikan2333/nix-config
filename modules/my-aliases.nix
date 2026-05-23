{
  config,
  lib,
  ...
}: {
  options.my.aliases.enable =
    lib.mkEnableOption "Enable custom aliases";

  config = lib.mkIf config.my.aliases.enable {
    programs.zsh.shellAliases = lib.mkMerge [
      {
        ll = "eza -la";
        lla = "eza -la --hyperlink"; # Nowy alias z obsługą linków
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

        # Informowanie Emacsa o aktualnym katalogu w vtermie
        vterm_printf() {
            if [ -n "$TMUX" ] && ([ "''${TERM%%-*}" = "tmux" ] || [ "''${TERM%%-*}" = "screen" ]); then
                # Tell tmux to pass the escape sequences through
                printf "\ePtmux;\e\e]%s\e\\\e\\" "$1"
            elif [ "''${TERM%%-*}" = "screen" ]; then
                # Screen
                printf "\eP\e]%s\e\\\e\\" "$1"
            else
                # Normal terminals
                printf "\e]%s\e\\" "$1"
            fi
        }
        
        # Wywoływane automatycznie przy każdej zmianie katalogu
        chpwd_functions+=(vterm_chpwd)
        vterm_chpwd() {
            vterm_printf "51;A$(pwd)"
        }
      ''
    ];
  };
}
