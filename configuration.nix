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
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # Enable dynamic-link libraries...
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    stdenv.cc.cc.lib
  ];

  # Enable windowing systems.
  # X11
  services.xserver.enable = true;
  #X Wayland
  #services.xwayland.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable XFCE
  #services.xserver.desktopManager.xfce.enable = true;

  # For river 
  services.displayManager.sessionPackages = [ pkgs.river ];

  # Second WM
  #programs.hyprland.enable = true;

  programs.waybar.enable = true;

  # Configure keymap in X11
  services.xserver = {
    xkb.layout = "pl";
    xkb.variant = "";
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
    socketActivation = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
    #wireplumber.enable = true;
  };

  # Manpages
  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;
  documentation.man.generateCaches = true;

  
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adam = {
    isNormalUser = true;
    description = "Adam";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      # Editors.
      vscodium

      # Desktop aplications.
      #(obsidian.overrideAttrs (old: rec {
      #    version = "1.4.16";
      #	  name = "obsidian-${version}";
      #	})
      #)
      obsidian

      # Do not delete those. Uncomment when needed.
      # audacity
      # wireshark
      # gimp
      # vlc
      # blender
      # filezilla
      # krita

      # Terminal tools && just tools.
      gnumake
      coreutils
      htop
      plocate
      tree
      wget
      curl
      git
      cron
      binwalk
      strace
      ltrace
      tmux
      openssh
      killall
      stow
      pavucontrol
      unzip

      # Special rust tools.
      bat
      ripgrep
      bacon
      du-dust
      ncspot
      rtx
      porsmo
      wiki-tui
      speedtest-rs

      # Programming.
      rustup
      rust-analyzer
      python3
      ghc
	  pkg-config
	  nodejs_22

      # Style points.
      neofetch

	  # For neovim-treesitter
      vimPlugins.nvim-treesitter.withAllGrammars
	  tree-sitter
    ];
  };

  programs.zsh.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    source-code-pro
    font-awesome
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Desktop config
  programs.river.enable = true;
  programs.river.xwayland.enable = true;

  # For window managers
  # F*** you Nvidia - Linus
  environment.sessionVariables = {

    # Against invisible cursors
    WLR_NO_HARDWARE_CURSORS = 1;

    # Hint electron apps to use wayland
    NIXOS_OZONE_WL = 0;

    # This is saddly a must
    EDITOR = "nvim";
    VISUAL = "nvim";

    # Firefox please work!
    XDG_CURRENT_DESKTOP = "river";
    MOZ_ENABLE_WAYLAND = 1;
  };

  # Nvidia wayland config continuation
  hardware = {
    opengl.enable = true;
    nvidia.modesetting.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
        xdg-desktop-portal-wlr
    ];
    wlr = {
      enable = true;
      #   settings = {
      #     screencast = {
      #      chooser_type = "simple";
      #      chooser_cmd = "${pkgs.slurp}/bin/slurp -f %o -or";
      #   };
      # };
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  	clang
    vim

    # Things needed for a river desktop session (enabled for all users)
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
    networkmanagerapplet # please guess :)

    # Fonts
    fira-code
    fira-code-symbols
    source-code-pro
    font-awesome
    
    # File manager
    gnome.nautilus
    #rox-filer

    # Printer management
    #system-config-printer
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
  system.autoUpgrade.enable = true; 

  # Turn flakes on
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
