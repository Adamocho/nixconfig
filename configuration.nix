{ config, pkgs, inputs, ... }:

{
  imports =
    [ # Hardware scan
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.systemd.enable = true;
  boot.plymouth.enable = true;
  boot.kernelParams = ["quiet"]; # Is this optional?

  boot.initrd.luks.devices."luks-0490d2ff-d1d3-4149-b887-0c79f72d299a".device = "/dev/disk/by-uuid/0490d2ff-d1d3-4149-b887-0c79f72d299a";
  networking.hostName = "earth";

  # For the SSD
  services.fstrim.enable = true;

  # Enable networking.
  networking.networkmanager.enable = true;

  # Time zone and locals.
  time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable windowing systems.
  # X11
  services.xserver.enable = true;
  # Wayland
  # services.wayland.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # For river 
  services.xserver.displayManager.sessionPackages = [ pkgs.river ];

  # Configure keymap in X11
  services.xserver = {
    layout = "pl";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Manpages
  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;
  documentation.man.generateCaches = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # This is saddly a must
  environment.variables.EDITOR = "nvim";
  environment.variables.VISUAL = "nvim";
  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adam = {
    isNormalUser = true;
    description = "Adam";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [

      # Editors.
      vscodium

      # Desktop aplications.
      obsidian
      # audacity
      # wireshark
      # gimp
      # vlc
      # blender
      # filezilla
      # krita

      # Terminal tools && just tools.
      coreutils
      htop
      plocate
      tree
      wget
      curl
      git
      zsh
      cron
      binwalk
      strace
      ltrace
      tmux
      openssh
      # Special rust tools
      bat
      ripgrep
      bacon
      du-dust

      # Programming.
      rustup
      rust-analyzer
      python3

      # Style points.
      neofetch
    ];
  };

  # Nix is upset about this
  nixpkgs.config.permittedInsecurePackages = [
    "electron-25.9.0"
  ];

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    source-code-pro
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Desktop config
  programs.river.enable = true;

 # programs.hyprland = {
 #   enable = true;
 #   nvidiaPatches = true;
 #   xwayland.enable = true;
 # };

  # For window managers
  # F*** you nvidia - Linus
  environment.sessionVariables = {
    # Against invisible cursors
    WLR_NO_HARDWARE_CURSORS = "1";
    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = "1";
  };

  # Nvidia wayland config continuation
  hardware = {
    opengl.enable = true;
    nvidia.modesetting.enable = true;
  };

  # Portals
  xdg.portal.enable = true;
  xdg.portal.wlr.enable = true;
  #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim
    (waybar.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
      })
    )
    dunst # notification daemon
    libnotify # notification display program
    # wallpaper
    (wbg.overrideAttrs (oldAttrs: {
        mesonFlags = oldAttrs.mesonFlags ++ [ "-Dpng=enabled" "-Djpeg=enabled" "-Dwebp=enabled" ];
      })
    )
    bemenu # dmenu for wayland
    firefox # browser
    alacritty # terminal
    networkmanagerapplet # guess :)
    # Fonts
    fira-code
    fira-code-symbols
    source-code-pro
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  
  # Turn flakes on
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
