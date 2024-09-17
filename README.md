# Nixos configuration

## Setup from scratch (without repo cloning)

### Base install

1. Install from CD/USB

2. Check `hardware-confituration.nix` and `configuration.nix` files for ambiguity

3. Change the default hostname to something you like:
```nix
  networking.hostname = "yourhostname";
```

4. Rebuild with `sudo nixos-rebuild switch`

5. Add `vim` text editor:
```diff
  # It should be somewhere in the configuration.nix
  environment.systemPackages = with pkgs; [
+    vim
  ];
```

Rebuild.

### Hardware optimisations

1. If you habe SSD:
```diff
# configuration.nix
+  services.fstrim.enable = true;

# hardware-configuration.nix
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/YOUR-SSD-DISK-ID";
    fsType = "ext4";
+    # For a long and healthy SSD life
+    options = [ "noatime" ];
    };
```

2. Hardware firmware problems
```diff
# configuration.nix
+  nixpkgs.config.allowUnfree = true;

# hardware-configuration.nix
+  hardware.enableAllFirmware = true;
```

Rebuild.

### Introducing flakes

1. Add experimental feature:

```diff
# configuration.nix
+  # Turn flakes on
+  nix.settings.experimental-features = [ "nix-command" "flakes" ];
```

Rebulid.

2. Initialize flakes

New file `flake.nix`

```nix
{
  description = "nix flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11"; # or 'nixos-unstable' if you want
    };
  
  outputs = { self, nixpkgs, ... } @inputs: {
    nixosConfigurations.yourhostname = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux"; # Or other if you have - check hardware config
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
      ];
    };
  };
}
```

> NOTE:
From now on you need to always rebuild the system with `sudo nixos-rebuild switch --flake /etc/nixos#yoursethostname`, so that you can have multiple flakes for different system configurations, e.g. server, nix on Rpi, cloud, laptop, etc.
Rebuild.

### Additional config

1. Plymouth startup screen

```diff
# configuration.nix
+  boot.plymouth.enable = true;
+  boot.kernelParams = ["quiet"]; # Is this optional?
```

2. Manpages

```diff
# configuration.nix
+  documentation.enable = true;
+  documentation.dev.enable = true;
+  documentation.man.enable = true;
+  documentation.man.generateCaches = true;
```

3. More packages

Just place them inside the `packages = with pkgs; [` array

4. EOL Electron problem solving (when installing obsidian)

```diff
# configuration.nix
+  nixpkgs.config.permittedInsecurePackages = [
+    "electron-25.9.0" # An example version used
+  ];
```

### Setting font

1. Install with `packages = with pkgs; [`

2. Then, make it available for system applications

```nix
# configuration.nix
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
    source-code-pro
  ];
```

Rebuild.

### Neovim as the default editor

```nix
# configuration.nix
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };
```

## Good to know

### Getting information

```bash
man configuration.nix
```

### Searching for packages

Visit **(nixos package search website)[https://search.nixos.org]**.

### Updating packages (with flakes)

Add channel for your desired package repo (e.g. 23.11 or unstable)
And then pull the newest packages with...
```bash
nix flake update
```
...to update flake's dependencies and packages


## Installing and setting up river (wayland wm)

Enable river in `configuration.nix` and install additional stuff
```nix
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
  };

    # IN THE SAME FILE

  # Desktop config
  programs.river.enable = true;

  # For window managers
  # F*** you Nvidia - Linus
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
  # Doesnt work - package conflict
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
```

Disable GNOME (it has conflicting packages).
It solved the issue in my case.
```diff
  services.xserver.displayManager.gdm.enable = true;
-  services.xserver.desktopManager.gnome.enable = true;
+  # services.xserver.desktopManager.gnome.enable = true;
```

Rebuild. Test. Rollback, should you need it.


## Laptop setup

This section is dedicated to setting up Nixos on a Framework 13 Laptop

### Nixos configuration file

All in all, the config used is pretty standard, although thanks to AMD, no Nvidia-related problems emerged - and I love it.

I didn't manage to get plymouth working so far, so maybe it's worth to investigate this further in the future. For now, I don't mind typing the encrypt password in without any fancy splash screen.

Everything worked out of the box, and I'm satisfied.

### Dotfiles

Some of the files like `.zshenv` and others must be commented out, because nixos can handle things like `cargo` and `node` without a problem.

It's surprisingly satisfying to clone the git repo, execute a script or two and it all just magically starts working; neovim looks and feels amazing, git and others require no hassle whatsoever.

### Screen scaling - addressing the elephant in the room

Due to high DPI of the screen, the raw look is unacceptable and for me personally eye-harming to say the least.

Things to do:
- Install gnome.mutter and then execute command:
    ```bash
    gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
    ```
    This enables fractional scaling in the `Display` section of gnome settings. Set this to 1.5 and you're good to go.
- Firefox: go to `about:config` type `devp` and change dpi scaling to whatevery you like - for me it's `1.5`;
- Vscodium: `zoom` and `font-size`;
- Obsidian: Same as above. 
- Other apps: Maybe the `font-size` in gnome-tweaks is too small or the app has it's own saling properties.

### Rebuilding Nixos

With my current config it's laughably easy to change anything and rebuild the system.
Just use:
```bash
# It figures out the machine type on its own
sudo nixos-rebuild switch --flake .
```
or my custom script:
```bash
./rebuild
```
