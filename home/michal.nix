{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ../modules/wezterm.nix
    ../modules/zsh.nix
   

    ./zsh/core.nix
    ./zsh/vi-mode.nix
    #./zsh/vim-indicator.nix
    #./zsh/prompt.nix
  ];
 

  home.username = "michal";
  home.homeDirectory = "/home/michal";

  home.file.".emacs.d/init.el".source = ../init.el;

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

 
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    home-manager
    kitty
    jetbrains-mono
    isync
    pass
    aerc
    thunderbird
    superfile
    
  ];
  programs.zellij = {
    enable = true;
    # Automatycznie podpina Zellija pod Zsh, jeśli chcesz (opcjonalnie)
    # enableZshIntegration = true; 

    settings = {
      default_mode = "normal";
      pane_frames = false; # Czysty ekran bez grubych ramek wokół okien
      theme = "default";
      
      # Tutaj w przyszłości możemy łatwo mapować skróty klawiszowe w formacie KDL
      keybinds = {
        # unbind = true; # Jeśli zechcesz kiedyś wyczyścić domyślne skróty
      };
    };
  };

  # Włączenie i konfiguracja GPG
  programs.gpg = {
    enable = true;
  };

  # Uruchomienie agenta GPG jako usługi w tle
  services.gpg-agent = {
    enable = true;
    # Używamy pinentry-curses, aby okienko wpisywania hasła pojawiało się bezpośrednio w terminalu
    pinentryPackage = pkgs.pinentry-curses;
    
    # Opcjonalnie: czas pamiętania hasła (np. 2 godziny, żeby nie wpisywać co chwilę)
    defaultCacheTtl = 7200;
    maxCacheTtl = 86400;
  };
  
  home.stateVersion = "25.05";
}
