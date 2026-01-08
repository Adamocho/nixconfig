{
  modulesPath,
  lib,
  pkgs,
  ...
} @ args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
    pkgs.busybox
  ];

  users.users.root.initialPassword = "1234";
  users.users.root.openssh.authorizedKeys.keys =
  [
    # SSH key to connect to the machine after installation
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCBtDRJHI9udg96j/Pn/pqF7olV8X3GEKCOx/vURrPaIKXIH1O+TVbBYl7btAAH4Tjs0ZHlUfRCxaEBgf4nWu555DFRkJM42/MF9VYPEkYqakONWmYqN/jM0Pot23ygdLAgO7szqK1ZSFbKu8xso/s+KmHjZiOq1OwgtkkUBwXBjBVaDnToAadzaq4y003YwFIYnVIb06Bewqr8ebjseXCIW7cHy61KRlzymqsUShGIChnkJV71nn4pgoFPUEmoxMECa2gNm7iRGrXXIFV4B2BI5r3RRfnLSqOzzhzujZdVf7nHpkCy4kc2vn2xOWKqAXJT4xZvAoNQilwq/JqyWPl/FuhXYXv5BVAIZVfEkg/7O5DXUrNlsAOoOEvjturWXsBeT9oc36jgOLBEj7pMQJ1ie6tJ1yDZ1sEI9Hb+stYcBQPvvITN05hBWZGKbcqcnt0c7N9UawmSMfDKQSCUkBwCoyRQzaM2AvBpV+FYBwKMte3kIyNA1r9NZxSQNpikQM/KSEbOzIRfbXBL+UkCW99xZigamiHwbbVA687apzndpp4WN/zq2LbE2amdFNjGfodtIIZ/cDSIr80Pn2kiqXtlAqT/Lun6bFoedKzY2oYkXBHU38YhqqJwvTRb+EbXSCm9yH2GLU4VGwT/hKHolfs443YKnApoQx2UD3bB1vTwHQ=="
  ];

  system.stateVersion = "24.05";
  # Flakes!!
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
