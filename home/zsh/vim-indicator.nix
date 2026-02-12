{ config, lib, ... }:

{
  programs.zsh.initContent = ''
    # ===============================
    # VIM MODE INDICATOR (state only)
    # ===============================

    VIM_MODE="INS"

    function zle-keymap-select {
      case $KEYMAP in
        vicmd)  VIM_MODE="NOR" ;;
        viins)  VIM_MODE="INS" ;;
        visual) VIM_MODE="VIS" ;;
        *)      VIM_MODE="INS" ;;
      esac
      zle reset-prompt
    }

    zle -N zle-keymap-select
  '';
}

