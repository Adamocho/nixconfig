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

### Ricing

To be continued...

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


