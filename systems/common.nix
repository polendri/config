# Configuration common to all systems.

{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # NixOS
  system.stateVersion = "18.03";
  nixpkgs.config.allowUnfree = true;

  # Boot
  boot.cleanTmpDir = true;

  # Hardware
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking and firewall
  networking = {
    firewall.allowPing = true;
    nameservers = [
      "209.222.18.222"  # PIA nameservers
      "209.222.18.218"  #
    ];
  };

  # Localization and console
  i18n = {
    defaultLocale = "en_CA.UTF-8";
  };
  time.timeZone = "America/Vancouver";

  # Users
  users = {
    mutableUsers = false;
    users.pshendry = {
      description = "Paul Hendry";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      uid = 1000;
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    curl
    git
    iftop
    iotop
    mkpasswd
    nox
    rsync
    tmux
    traceroute
    unzip
    vim
    zip
  ];
}

