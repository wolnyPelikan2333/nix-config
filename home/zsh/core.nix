{ config, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;


    
    initContent = lib.mkAfter ''
      # sen — sudo nvim helper
      sen() {
        if [ "$#" -eq 0 ]; then
          sudo -E nvim .
        else
          sudo -E nvim "$@"
        fi
      }

      mklesson-bulk() {
        [[ -f TEMPLATE.md ]] || { echo "Brak TEMPLATE.md"; return 1; }

        for d in */; do
          [[ ! -s "$d/README.md" ]] && cp TEMPLATE.md "$d/README.md"
        done
      }
        # --- auto tmux main session ---
        if command -v tmux >/dev/null \
          && [ -z "$TMUX" ] \
          && [ -n "$PS1" ]; then
          tmux new -A -s main
        fi

      
      
    '';
  };
}

