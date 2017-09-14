# NixOS configuration for psh-desktop

{ config, pkgs, ... }:

{
  imports = [
    ../server.nix
    ../workstation.nix
  ];

  # Boot and filesystems
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/065D-F564";
    fsType = "vfat";
  };
  fileSystems."/mnt/data_ssd" = {
    device = "/dev/disk/by-uuid/0F6B1D7004144BCF";
    fsType = "ntfs";
  };
  fileSystems."/mnt/data_hdd" = {
    device = "/dev/disk/by-uuid/7FD9AE414EA2CDDA";
    fsType = "ntfs";
  };

  # Hardware
  services.xserver.videoDrivers = [ "nvidia" ];

  # Networking and firewall
  networking.hostName = "psh-desktop";

  # Users
  users.users.pshendry = {
    extraGroups = [ "wheel" "networkmanager" "docker" "plugdev" "vboxusers" ];
    hashedPassword = "$6$BDYu5YVfS710L9R$NZVWs2WMhrKFGGvYRRzK7wqlZik71rPYcXSCx.c.rq8Nm5tjeS.SiwdnU.1/sIODZ1LPBYhPgT3LZNIGXmRza0";
  };

  # System packages
  environment.systemPackages = with pkgs; [
    androidsdk
  ];
}

