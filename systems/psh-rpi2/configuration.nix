# NixOS configuration for psh-rpi2
#
# See https://nixos.wiki/wiki/NixOS_on_ARM

{ config, pkgs, lib, ... }:

{
  imports = [
    ../server.nix
  ];

  # NixOS
  nix.binaryCaches = lib.mkForce [ "http://nixos-arm.dezgeg.me/channel" ];
  nix.binaryCachePublicKeys = [ "nixos-arm.dezgeg.me-1:xBaUKS3n17BZPKeyxL4JfbTqECsT+ysbDJz29kLFRW0=%" ];

  # Boot and filesystems
  boot = {
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/NIXOS_BOOT";
      fsType = "vfat";
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  swapDevices = [ { device = "/swapfile"; size = 1024; } ];

  # Networking and firewall
  networking = {
    firewall = {
      allowedTCPPorts = [
        58846  # Deluge daemon
      ];
    };
    hostName = "psh-rpi2";
  };

  # Users
  users.users.pshendry = {
    hashedPassword = "$6$yW2vUwpt6tyWTOw$Z6dYy1S7Of1O/f5aZBPmDRVdHkdKnLoxtBgj7Ar.g4sdlnxA0/BnXogf8mWn1zrd4iCQJG1sCAfBH7y7K6Bq5/";
  };

  # Services
  services.deluge.enable = true;

  # System packages
  #environment.systemPackages = with pkgs; [
  #];
}

