{ config, lib, ... }:

{
  programs.zsh.initContent = ''
    # ===============================
    # ZSH RPROMPT — vim mode indicator
    # ===============================
    setopt PROMPT_SUBST
    autoload -Uz colors && colors

    function _vim_mode_rprompt() {
      case "$VIM_MODE" in
        NOR) print -n "%{$fg[red]%}NOR%{$reset_color%}" ;;
        INS) print -n "%{$fg[green]%}INS%{$reset_color%}" ;;
        VIS) print -n "%{$fg[yellow]%}VIS%{$reset_color%}" ;;
        *)   print -n "%{$fg[green]%}INS%{$reset_color%}" ;;
      esac
    }

    RPROMPT='$(_vim_mode_rprompt)'
  '';
}

