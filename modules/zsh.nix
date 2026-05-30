{ config, pkgs, lib, ... }: {

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    dotDir = "${config.xdg.configHome}/zsh";
    defaultKeymap = "emacs";

    # 1. Zmienne sesyjne wewnątrz modułu Zsh
    sessionVariables = {
      MPC_HOST = "127.0.0.1";
      MPC_PORT = "6600";
      PATH = "$HOME/bin:$PATH";
      EDITOR = "emacs";
      VISUAL = "emacs";
    };

    # 2. Konfiguracja historii powłoki
    history = {
      path = "$HOME/.config/zsh/.zsh_history";
      size = 100000;
      save = 100000;
      share = false;
      ignoreDups = true;
      extended = true;
    };

    # 3. Wszystkie Twoje oficjalne aliasy systemowe
    shellAliases = {
      # Podstawowe
      w = "w3m";
      nixman = "w3m https://nixos.org/manual/nixos/stable/";
      nixerr = "less /etc/nixos/docs/ściągi/nix/nix-build-errors.md";
      st = "sys-status";
      sys-status = "sys-status";
      sesja-start = "sesja-start";
      docs = "docs";
      lab = "cd /home/michal/lab/";
      nss-check = "/home/michal/git-sterile/scripts/nss-check";
      okbuild = "test -f /etc/nixos/OK_TO_BUILD && echo OK || echo NIE_BUDUJ";
      nss = "nix-rentgen";
      hst = "nix-historia";
      usp = "systemctl suspend";

      # LSD
      ls = "lsd";
      ll = "lsd -l";
      la = "lsd -a";
      lla = "lsd -la";
      lt = "lsd --tree";
      l2 = "lsd --tree --depth 2";
      ls0 = "/bin/ls";

      # Git
      g = "git";
      gs = "git status -sb";
      gl = "git log --oneline --graph --decorate -10";
      gba = "git branch -a";
      gco = "git checkout";
      gcb = "git checkout -b";
      ga = "git add";
      gaa = "git add -A";
      gd = "git diff";
      gdc = "git diff --cached";
      gr = "git restore";
      grs = "git restore --staged";
      gc = "commit";
      gcm = "git commit -m";
      gp = "git push";
      gpl = "git pull --ff-only";
      grh = "git reset --hard";
    };

    # 4. Skrypty startowe powłoki (w tym naprawa promptu i git_repo_hint)
    initExtra = ''
      # Naprawa promptu $(git_repo_hint)
      setopt PROMPT_SUBST

      autoload -Uz colors
      colors

      # --- PANIC TRIGGER ---
      krasnoludki() {
        panic-stop
        exit
      }

      gargamel() {
        panic-stop
        exit
      }

      # PROMPT i funkcja pomocnicza Git
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

      # BROOT
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

      eval "$(direnv hook zsh)"
      eval "$(zoxide init zsh)"
      source <(fzf --zsh)

      bindkey -e
    '';
  };
}
