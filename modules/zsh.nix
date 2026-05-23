{
  config,
  pkgs,
  lib,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "emacs";

    sessionVariables = {
      MPC_HOST = "127.0.0.1";
      MPC_PORT = "6600";
    };

    history = {
      path = "$HOME/.config/zsh/.zsh_history";
      size = 100000;
      save = 100000;
      share = false;
      ignoreDups = true;
      extended = true;
    };

    # ==========================================================
    # INIT CONTENT — nowoczesne, połączone środowisko powłoki
    # ==========================================================
    initContent = ''
      # ----------------------------------------------------------
      # PODSTAWY I SYSTEMOWY PATH
      # ----------------------------------------------------------
      autoload -Uz colors
      colors
      export PATH="$HOME/bin:$PATH"

      # --- PANIC TRIGGER ---
      krasnoludki() {
        panic-stop
        exit
      }

      gargamel() {
        panic-stop
        exit
      }

      # ----------------------------------------------------------
      # OPCJE HISTORII
      # ----------------------------------------------------------
      setopt APPEND_HISTORY
      setopt INC_APPEND_HISTORY
      setopt HIST_REDUCE_BLANKS
      setopt HIST_SAVE_NO_DUPS
      setopt PROMPT_SUBST

      # ----------------------------------------------------------
      # PROMPT (Zintegrowany indykator Git)
      # ----------------------------------------------------------
      git_repo_hint() {
        git rev-parse --is-inside-work-tree &>/dev/null || return

        local hint=""
        local branch

        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD)

        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
          hint="*"
        fi

        if git rev-parse --abbrev-ref @{u} >/dev/null 2>&1; then
          if [ "$(git rev-list --count @{u}..HEAD)" -gt 0 ]; then
            hint="$hint↑"
          fi
        fi

        echo " ($branch$hint)"
      }

      PROMPT=$'\n%{\e[38;5;220m%}%~%{\e[0m%}$(git_repo_hint)\n%{\e[38;5;81m%}❯%{\e[0m%} '

      # ----------------------------------------------------------
      # INTEGRACJA BROOT (Funkcja powłoki)
      # ----------------------------------------------------------
      br() {
        local cmd cmd_file
        cmd_file=$(mktemp)
        if broot --outcmd "$cmd_file" "$@"; then
          cmd=$(<"$cmd_file")
          rm -f "$cmd_file"
          eval "$cmd"
        else
          rm -f "$cmd_file"
          return 1
        fi
      }

      

      # ----------------------------------------------------------
      # ALIASY (Skróty do binariów oraz nowych skryptów)
      # ----------------------------------------------------------
      alias w="w3m"
      alias nixman="w3m https://nixos.org/manual/nixos/stable/"
      alias nixerr="less /etc/nixos/docs/ściągi/nix/nix-build-errors.md"
      alias st="sys-status"
      alias sys-status="sys-status"
      alias sesja-start="sesja-start"
      alias docs="docs"
      alias lab="cd /home/michal/lab/"
      alias nss-check="/home/michal/git-sterile/scripts/nss-check"
      alias okbuild="test -f /etc/nixos/OK_TO_BUILD && echo OK || echo NIE_BUDUJ"
      alias nss="nix-rentgen"
      alias hst="nix-historia" # 🌟 NOWY ALIAS DO HISTORII

      # LSD — nowoczesne zamienniki ls
      alias ls='lsd'
      alias ll='lsd -l'
      alias la='lsd -a'
      alias lla='lsd -la'
      alias lt='lsd --tree'
      alias l2='lsd --tree --depth 2'
      alias ls0='/bin/ls'

      # GIT — aliasy rzemieślnicze
      alias g='git'
      alias gs='git status -sb'
      alias gl='git log --oneline --graph --decorate -10'
      alias gba='git branch -a'
      alias gco='git checkout'
      alias gcb='git checkout -b'
      alias ga='git add'
      alias gaa='git add -A'
      alias gd='git diff'
      alias gdc='git diff --cached'
      alias gr='git restore'
      alias grs='git restore --staged'
      alias gc='git commit'
      alias gcm='git commit -m'
      alias gp='git push'
      alias gpl='git pull --ff-only'
      alias grh='git reset --hard'

      # ----------------------------------------------------------
      # AKTYWACJA ZEWNĘTRZNYCH NARZĘDZI I MAPY EMACSA
      # ----------------------------------------------------------
      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"
      source <(fzf --zsh)

      # Żelazne, ostateczne wymuszenie mapy emacsa (zawsze na samym dole!)
      bindkey -e
    '';
  };
}
