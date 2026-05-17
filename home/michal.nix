{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../modules/wezterm.nix
    ../modules/zsh.nix
    ../modules/my-aliases.nix

    ./zsh/core.nix
    ./zsh/vi-mode.nix
    #./zsh/vim-indicator.nix
    #./zsh/prompt.nix
  ];
  my.aliases.enable = true;

  home.username = "michal";
  home.homeDirectory = "/home/michal";

  home.sessionVariables = {
    EDITOR = "emacs";
    VISUAL = "emacs";
  };

  programs.fzf.enable = true;
  programs.bat.enable = true;
  programs.eza.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.alacritty = {
    enable = true;

    settings = {
      env = {
        TERM = "xterm-256color";
      };

      window = {
        decorations = "full";
        dynamic_padding = true;
      };

      font = {
        normal = {
          family = "JetBrains Mono";
          style = "Regular";
        };
        size = 12.0;
      };

      scrolling = {
        history = 10000;
      };

      cursor = {
        style = "Block";
        unfocused_hollow = true;
      };

      selection = {
        save_to_clipboard = true;
      };

      keyboard = {
        bindings = [
          # --- Clipboard ---
          {
            key = "C";
            mods = "Alt";
            action = "Copy";
          }
          {
            key = "V";
            mods = "Alt";
            action = "Paste";
          }

          # --- Window ---
          {
            key = "N";
            mods = "Alt";
            action = "CreateNewWindow";
          }
          {
            key = "Q";
            mods = "Alt";
            action = "Quit";
          }

          # --- Font size ---
          {
            key = "Equals";
            mods = "Alt";
            action = "IncreaseFontSize";
          }
          {
            key = "Minus";
            mods = "Alt";
            action = "DecreaseFontSize";
          }
          {
            key = "Key0";
            mods = "Alt";
            action = "ResetFontSize";
          }

          # --- Neovim leader mappings (chars = "...") ---
          # Alt+P -> ,p
          {
            key = "P";
            mods = "Alt";
            chars = ",p";
          }

          # (na później, jeśli będziesz chciał)
          # Alt+F -> ,f
          {
            key = "F";
            mods = "Alt";
            chars = ",f";
          }

          # Alt+G -> ,g
          {
            key = "G";
            mods = "Alt";
            chars = ",g";
          }

          # Alt+Y -> ,y
          {
            key = "Y";
            mods = "Alt";
            chars = ",y";
          }
        ];
      };
    };
  };

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    home-manager
    zellij
    kitty
    jetbrains-mono
    isync
    pass
    gnupg
    pinentry-curses
    aerc
    thunderbird
    superfile
    (writeShellScriptBin "pytaj-mape" ''
  if [ -z "$1" ]; then
      echo "Musisz zadać jakieś pytanie, np: pytaj-mape \"Co mam w notatkach?\""
      exit 1
  fi

  KONTEKST=$(${findutils}/bin/find ~/mapa -type f ! -name ".*" ! -name "*~" -name "*.org" -exec cat {} +)

  echo "Analizuję całą Mapę (RTX 3050)..."

  # Wstrzykujemy sterowniki graficzne bezpośrednio do środowiska uruchomieniowego Ollamy
  cat << END_OLLAMA | LD_LIBRARY_PATH=/run/opengl-driver/lib:$LD_LIBRARY_PATH ${ollama}/bin/ollama run llama3
Jesteś osobistym asystentem. Masz dostęp do moich notatek z folderu mapa, które załączam poniżej. Odpowiedz na pytanie użytkownika, bazując na tych informacjach. Odpowiedz WYŁĄCZNIE po polsku.

--- NOTATKI ---
$KONTEKST
---

Pytanie: $*
END_OLLAMA
'')
];
 
  home.stateVersion = "25.05";
}
