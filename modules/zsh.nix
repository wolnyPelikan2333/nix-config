
{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "viins";

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
    # INIT CONTENT — funkcje, aliasy, narzędzia
    # ==========================================================
    initContent = ''
      # ----------------------------------------------------------
      # PODSTAWY
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
      # HISTORIA
      # ----------------------------------------------------------
      setopt APPEND_HISTORY
      setopt INC_APPEND_HISTORY
      setopt HIST_REDUCE_BLANKS
      setopt HIST_SAVE_NO_DUPS

      # ----------------------------------------------------------
      # SESJA — START
      # ----------------------------------------------------------
      sesja-start() {
        echo "🧭 START SESJI"
        echo

        if [ -f /etc/nixos/SESJE/AKTYWNA.md ]; then
          echo "📄 Źródło startu:"
          echo "  → /etc/nixos/SESJE/AKTYWNA.md"
          echo
          nvim /etc/nixos/SESJE/AKTYWNA.md
        else
          echo "❌ BŁĄD STARTU SESJI"
          echo
          echo "Brak pliku:"
          echo "  /etc/nixos/SESJE/AKTYWNA.md"
          return 1
        fi
      }

      # ----------------------------------------------------------
      # SYSTEM STATUS
      # ----------------------------------------------------------
      sys-status() {
        echo "===== SYSTEM STATUS ====="
        echo

        echo "📊 Uptime:"
        uptime | sed 's/^/  /'
        echo

        echo "💾 Disk /:"
        df -h / | sed '1d;s/^/  /'
        echo

        echo "🔐 Repo (/etc/nixos):"

        local modified untracked
        modified=$(git -C /etc/nixos status --porcelain | grep -c '^ M')
        untracked=$(git -C /etc/nixos status --porcelain | grep -c '^??')

        if [ "$modified" -eq 0 ] && [ "$untracked" -eq 0 ]; then
          echo "  Stan: CLEAN ✔"
        else
          echo "  Stan: DIRTY ✖"
          echo "    M  $modified"
          echo "    ?? $untracked"
        fi

        local ahead behind
        ahead=$(git -C /etc/nixos rev-list --count @{u}..HEAD 2>/dev/null || echo 0)
        behind=$(git -C /etc/nixos rev-list --count HEAD..@{u} 2>/dev/null || echo 0)

        echo
        echo "  Commit: ahead=$ahead behind=$behind"
        echo
        git -C /etc/nixos log -1 --pretty='  %h  "%s"' 2>/dev/null
      }

      # ----------------------------------------------------------
      # DOCS
      # ----------------------------------------------------------
      docs() {
        local file
        file=$(cd /etc/nixos/docs || return
          find . -type f |
          sed 's|^\./||' |
          fzf --prompt="docs> " \
              --preview 'bat --style=numbers --color=always {} 2>/dev/null || sed -n "1,200p" {}'
        )
        [[ -n "$file" ]] && nvim "/etc/nixos/docs/$file"
      }

      # ----------------------------------------------------------
      # NBUILD
      # ----------------------------------------------------------
      nbuild() {
        sudo nixos-rebuild build --flake /etc/nixos
      }

      # ----------------------------------------------------------
      # BROOT
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
      # ALIASY
      # ----------------------------------------------------------
      alias w="w3m"
      alias nixman="w3m https://nixos.org/manual/nixos/stable/"
      alias nixerr="less /etc/nixos/docs/ściągi/nix/nix-build-errors.md"
      alias st="sys-status"
      alias lab="cd /home/michal/lab/"
      alias nss-check="/home/michal/git-sterile/scripts/nss-check"
      alias okbuild="test -f /etc/nixos/OK_TO_BUILD && echo OK || echo NIE_BUDUJ"

      # ----------------------------------------------------------
      # LSD — lepsze ls (terminal / human only)
      # ----------------------------------------------------------
      alias ls='lsd'
      alias ll='lsd -l'
      alias la='lsd -a'
      alias lla='lsd -la'

      # orientacja w strukturze
      alias lt='lsd --tree'
      alias l2='lsd --tree --depth 2'

      # fallback klasyczny (skrypty / debug)
      alias ls0='/bin/ls'


      # ----------------------------------------------------------
      # GIT — aliasy
      # ----------------------------------------------------------
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

    '';

    # ==========================================================
    # PROMPT — TYLKO PROMPT (HOME MANAGER)
    # ==========================================================
    initExtra = ''
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
       # PATH dla Zsh
      export PATH="$HOME/.config/emacs/bin:$PATH"

      PROMPT=$'\n%{\e[38;5;220m%}%~%{\e[0m%}$(git_repo_hint)\n%{\e[38;5;81m%}❯%{\e[0m%} '
    '';
  };
}
