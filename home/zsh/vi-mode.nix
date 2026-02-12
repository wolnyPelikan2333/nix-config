{ config, lib, ... }:

{
  programs.zsh.initContent = ''
    # ===============================
    # ZSH VI MODE (foundation)
    # ===============================

    bindkey -v

    # ensure prompt refresh on mode init
    function zle-line-init {
      zle reset-prompt
    }
    zle -N zle-line-init
  '';
}

