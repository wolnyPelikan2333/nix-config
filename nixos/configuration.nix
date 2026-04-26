{
  config,
  pkgs,
  lib,
  ...
}:
{
  # test nss commit flow
  ###############################################
  ## IMPORTY
  ###############################################

  imports = [
    ./hardware-configuration.nix
    ../modules/packages.nix
  ];

  ###############################################
  ## GLOBALNE ZMIENNE
  ###############################################

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    SUDO_EDITOR = "nvim";
  };

  environment.shells = [ pkgs.zsh ];

  ###############################################
  ## BOOT
  ###############################################

  systemd.defaultUnit = "graphical.target";

  boot.loader = {
    systemd-boot.enable = true;
    systemd-boot.configurationLimit = 10;
    efi.canTouchEfiVariables = true;
  };

  boot.loader.timeout = 3;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  ###############################################
  ## NETWORK / LOCALE
  ###############################################

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Warsaw";

  i18n.defaultLocale = "pl_PL.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };

  ###############################################
  ## GRAFIKA / KDE
  ###############################################

  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.displayManager.defaultSession = "plasmax11";

  services.desktopManager.plasma6.enable = true;

  # Twarde wyłączenie Wayland
  services.displayManager.sddm.wayland.enable = false;
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "0";
    QT_QPA_PLATFORM = "xcb";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    CHROME_EXTRA_FLAGS = "--use-gl=desktop";
  };

  console.keyMap = "pl2";

  ###############################################
  ## NVIDIA
  ###############################################

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
    powerManagement.enable = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  ###############################################
  ## AUDIO
  ###############################################

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = false;

    wireplumber.extraConfig = {
      "10-bluez-priority" = {
        "monitor.bluez.rules" = [
          {
            matches = [
              { "node.name" = "~bluez_output.*"; }
            ];
            actions = {
              update-props = {
                "priority.session" = 2000;
              };
            };
          }
        ];
      };
    };
  };

  security.rtkit.enable = true;

  ###############################################
  ## BLUETOOTH
  ###############################################

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services.blueman.enable = true;

  ###############################################
  ## USER
  ###############################################

  users.users.michal = {
    isNormalUser = true;
    description = "michal";
    extraGroups = [
      "networkmanager"
      "wheel"
      "vboxusers"
      "bluetooth"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ kdePackages.kate ];
  };

  services.displayManager.autoLogin.enable = false;
  services.displayManager.autoLogin.user = null;

  services.flatpak.enable = true;

  ###############################################
  ## SYSTEM PACKAGES
  ###############################################

  nixpkgs.config = {
    allowUnfree = true;
    cudaSupport = true;
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    kdePackages.okular
    wget
    firefox
    google-chrome
    git
    nh
    fzf
    zoxide
    starship
    yazi
    ranger
    steam
    zathura
    discord
    lutris
    wineWowPackages.full
    winetricks
    libreoffice
    entr
    ddgr
    qutebrowser
    w3m
    lazygit
    bash-completion
    xclip
    lm_sensors
    btop
    broot
    taskwarrior
    (emacs.pkgs.withPackages (epkgs: [
      epkgs.apheleia
      epkgs.dashboard
      epkgs.magit
      epkgs.nix-mode
      epkgs.org
    ]))
    nixfmt-rfc-style
    coreutils
    ripgrep
    lact
    cmake
    gnumake
    gcc
    libtool
    ledger
    lsd
    vscode
    obsidian
    prismlauncher
    gparted
    blender
    bitwarden
    davinci-resolve
    ollama
    python3
    system-config-printer
    treefmt
    alejandra
    nodePackages.prettier
    nmap
    google-authenticator
  ];

  # automatyczne ładowanie modułów czujników
  hardware.sensor.iio.enable = true;

  environment.etc."chromium-flags.conf".text = ''
    --use-gl=desktop
  '';

  ###############################################
  ## ZSH
  ###############################################

  programs.zsh.enable = true;

  ###############################################
  ## FONTS
  ###############################################

  fonts.packages = with pkgs; [
    carlito
    caladea
    liberation_ttf
    nerd-fonts.jetbrains-mono
  ];

  ###############################################
  ## GC
  ###############################################

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-generations +10";
  };

  nix.settings.auto-optimise-store = true;

  ###############################################
  ## NH
  ###############################################

  programs.nh.enable = true;
  programs.nh.clean = {
    enable = false;
    dates = "weekly";
  };

  ###############################################
  ## ALIASES
  ###############################################

  environment.shellAliases = {
    ns = "nh os switch /etc/nixos#nixos";
    nt = "nh os test /etc/nixos#nixos";
    nb = "nh os boot /etc/nixos#nixos";
    nh-clean = "nh clean all && sudo nix-env --delete-generations +5 && sudo nix-collect-garbage -d";
  };

  ###############################################
  ## FILESYSTEMS
  ###############################################

  fileSystems."/mnt/steam" = {
    device = "/dev/disk/by-uuid/8fbe63e6-58f2-4609-905a-5f2365318224";
    fsType = "ext4";
    options = [
      "defaults"
      "nofail"
    ];
  };

  # ==========================================================
  # SWAP + HIBERNATE (NVIDIA SAFE MODE)
  # ==========================================================

  swapDevices = [
    {
      device = "/swapfile";
      size = 40960; # 40 GB (RAM 32 GB + zapas)
    }
  ];

  boot.resumeDevice = "/swapfile";

  services.logind.extraConfig = ''
    HandleSuspendKey=hibernate
    HandleLidSwitch=hibernate
    HandleLidSwitchExternalPower=hibernate
  '';

  security.doas = {
    enable = true;
    extraRules = [
      {
        groups = [ "wheel" ];
        persist = true;
      }
    ];
  };
  
  security.pam.services.sshd.googleAuthenticator.enable = true;
  # 2FA dla ekranu logowania i terminala lokalnego
  security.pam.services.sddm.googleAuthenticator.enable = true;
  security.pam.services.login.googleAuthenticator.enable = true;
  
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplip ];

  ###############################################
  ## BEZPIECZEŃSTWO
  ###############################################

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = true; # Wymagane dla 2FA
      PermitRootLogin = "no";
    };
    extraConfig = ''
      AuthenticationMethods publickey,keyboard-interactive
    '';
  };

  services.fail2ban.enable = true;

  ###############################################
  ## EMACS CONFIG
  ###############################################

  services.emacs = {
    enable = true;
    package = pkgs.emacs.pkgs.withPackages (epkgs: [
      epkgs.apheleia
      epkgs.dashboard
      epkgs.magit
      epkgs.nix-mode
      epkgs.org
    ]);
  };

  environment.etc."emacs/site-start.el".text = ''
    ;; 1. KONFIGURACJA PODSTAWOWA
    (setq inhibit-startup-screen t)
    (setq initial-scratch-message nil)

    ;; 2. RECENTF (Zapamiętywanie plików)
    (require 'recentf)
    (recentf-mode 1)
    (setq recentf-max-saved-items 100)

    ;; 3. DASHBOARD
    (require 'dashboard)
    (setq dashboard-items '((recents  . 15)
                            (bookmarks . 5)
                            (projects . 5)))
    (setq dashboard-set-heading-icons t)
    (setq dashboard-set-file-icons t)
    (setq dashboard-startup-banner 'official)
    
    ;; WYMUSZENIE DASHBOARDU (Metoda dla Emacs 30)
    (dashboard-setup-startup-hook)
    (setq initial-buffer-choice (lambda () (get-buffer-create "*dashboard*")))

    ;; 4. TWOJE TRYBY (Nix, Apheleia)
    (require 'nix-mode)
    (require 'apheleia)
    (setq apheleia-formatters
          '((nixfmt . ("/run/current-system/sw/bin/nixfmt-rfc-style"))))
    (setq apheleia-mode-alist '((nix-mode . nixfmt)))
    (apheleia-global-mode +1)
    (add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

    ;; 5. SZYBKI RATUNEK (Gdyby dashboard zniknął)
    (global-set-key (kbd "C-c d") (lambda () (interactive) (dashboard-refresh-buffer) (switch-to-buffer "*dashboard*")))
  '';
  
  ###############################################
  ## STATE
  ###############################################

  system.stateVersion = "25.05";
}
