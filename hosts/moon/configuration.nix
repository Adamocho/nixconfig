# Help is available in the configuration.nix(5) man page
{ pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  ## DaVinci/Chromium patch START
  boot.initrd.kernelModules = ["amdgpu"];

  hardware.graphics.extraPackages = with pkgs; [
    libvdpau
    vaapiVdpau
    amdvlk
    rocmPackages_5.clr.icd
    driversi686Linux.amdvlk # To enable Vulkan support for 32-bit applications.
  ];

  hardware.graphics = {
    enable = true;
    #driSupport = true;
    enable32Bit = true;
  };

  systemd.tmpfiles.rules = [
     "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages_5.clr}"
  ];
  ## Patch END

  # SSD optimization
  services.fstrim.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.configurationLimit = 15;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelParams = ["quiet"];
  boot.initrd.luks.devices."luks-eab86c67-aed2-4de4-acf8-0d7011cca2d6".device = "/dev/disk/by-uuid/eab86c67-aed2-4de4-acf8-0d7011cca2d6";
  networking.hostName = "moon";

  environment.sessionVariables = rec {
    GSK_RENDERER = "gl";
  };

  # System Emulation
  boot.binfmt.emulatedSystems = [
    # If needed (by crosscompiling)
  ];

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # Select internationalisation properties.
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };

  # Configure console keymap
  console.keyMap = "pl2";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Manpages
  documentation.enable = true;
  documentation.dev.enable = true;
  documentation.man.enable = true;
  # Takes too long - use the rebuild script instead.
  #documentation.man.generateCaches = true;

  # Enable dynamic-link libraries...
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
    stdenv.cc.cc.lib
  ];

  # Shell
  programs.zsh.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.adam = {
    isNormalUser = true;
    description = "Adam";
    extraGroups = [ "networkmanager" "wheel" "docker" ];
    shell = pkgs.zsh;
    packages = with pkgs; [
      # Applications
      gimp
      vlc
      blender
      audacity
      wireshark
      libreoffice
      obs-studio
      inkscape
      #filezilla
      krita
      tor-browser
      calibre

      # Communciation
      #discord
      #element-desktop

      # Text editors and others
      jetbrains.idea-ultimate
      vscodium
      obsidian
      alacritty
      tmux

      # Others
      bemenu
      asciinema
      magic-wormhole

      # Do not ask
      haskellPackages.haskell-language-server
      ghc
      stack

      # Gnome
      gnomeExtensions.just-perfection

      # Terminal tools && just tools.
      htop
      plocate
      binwalk
      strace
      ltrace
      killall
      stow
      #pavucontrol
      unzip

      # Special rust tools.
      fd
      bat
      ripgrep
      bacon
      du-dust
      ncspot
      porsmo
      wiki-tui
      speedtest-rs
      sccache
    ];
  };

  # Configure additional fonts
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    source-code-pro
    font-awesome
  ];

  # Install firefox.
  programs.firefox.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };


  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    tree
    wget
    curl
    file

    # Rust Yew
    #trunk 
    pkg-config
    pkg-config-unwrapped
    openssl
    libressl_3_8
    openssl_legacy
    clangMultiStdenv
    gccMultiStdenv

    # Languages, compilers and others
    gnumake
    cmake
    rustup
    rust-analyzer
    python3
    musl
    clang
    nodejs_20

    # For neovim-treesitter
    vimPlugins.nvim-treesitter.withAllGrammars
    tree-sitter

    # DE Gnome better looks
    gnome-tweaks
    mutter

    # Manpages
    man-pages
    man-pages-posix

    # graphics
    vulkan-tools
    mesa

    # power management
    powertop

    # Firmware update
    fwupd
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  # List services that you want to enable:

  # Enable cron service
  services.cron = {
    enable = true;
    # systemCronJobs = [
    #   "*/5 * * * *      root    date >> /tmp/cron.log"
    # ];
  };

  # Enable plocate database
  services.locate.enable = true;
  services.locate.package = pkgs.plocate;
  services.locate.interval = "weekly";
  services.locate.localuser = null;

  # Enable docker
  virtualisation.docker.enable = true;

  # Enable virt-manager for KVM
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = ["adam"];
  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable the OpenSSH daemon.
  #services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  # This value determines the NixOS release of the installed version.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  # Auto upgrades... this is Nixos, so it won't hurt anyway
  #system.autoUpgrade.enable = true; 

  # Flakes!!
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

