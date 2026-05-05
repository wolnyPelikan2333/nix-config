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
  services.displayManager.defaultSession = "plasma";

  services.desktopManager.plasma6.enable = true;

  

  # Skoro Wayland działał na KDE, zostawiamy to włączone dla SDDM
  services.displayManager.sddm.wayland.enable = true;
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
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
  nix.settings.trusted-users = [ "root" "michal" ];
  nix.settings.auto-optimise-store = true;

  nixpkgs.overlays = [
    # Overlay 1: Naprawa OpenLDAP (pomija testy)
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (oldAttrs: {
        doCheck = false;
        doInstallCheck = false;
      });
    })
    # Overlay 2: Emacs z Native Compilation
    (import (builtins.fetchTarball {
      url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
     sha256 = "0f5c8srk6gq31zdd24lzw8qv79bmdlaw27rpfyg5jix61fzz1zcj";
    }))
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
    wineWow64Packages.full
    winetricks
    libreoffice
    entr
    ddgr
    qutebrowser
    w3m
    lazygit
    bash-completion    xclip
    lm_sensors
    btop
    broot
    taskwarrior2
    nixfmt
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
    bitwarden-desktop
    davinci-resolve
    ollama
    python3
    system-config-printer
    treefmt
    alejandra
    prettier
    nmap
    google-authenticator
    kitty
    eza
    isync
    (mu.override { emacs = emacs; })
    # 1. Sam program Emacs z kompilacją natywną
    (pkgs.emacs-pgtk.override {
      withNativeCompilation = true;
      withTreeSitter = true;
    })

    # 2. Pakiety do tego konkretnego Emacsa (zwróć uwagę na podwójny nawias na początku!)
    ((pkgs.emacsPackagesFor pkgs.emacs-pgtk).withPackages (epkgs: [
      epkgs.apheleia
      epkgs.dashboard
      epkgs.magit
      epkgs.nix-mode
      epkgs.org
      epkgs.doom-themes
      epkgs.vterm
      epkgs.all-the-icons
      epkgs.doom-modeline
      epkgs.mu4e
    ]))
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

  #boot.resumeDevice = "/swapfile";

  services.logind.settings = {
    Login = {
      HandleSuspendKey = "hibernate";
      HandleLidSwitch = "hibernate";
      HandleLidSwitchExternalPower = "hibernate";
    };
  };
  
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
  # security.pam.services.sddm.googleAuthenticator.enable = true;
  # security.pam.services.login.googleAuthenticator.enable = true;
  
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
  ## STATE
  ###############################################

  system.stateVersion = "25.05";
}
