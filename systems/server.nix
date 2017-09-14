# Common configuration for any headless server.

{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  # NixOS
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Services
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
  };

  services.fail2ban.enable = true;

  # System packages
  #environment.systemPackages = with pkgs; [
  #];
}

