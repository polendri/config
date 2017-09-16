# NixOS configuration for psh-server
#
# Pre-install steps:
#   * Create or attach 'boot', 'swap', 'nixos' and 'data' partitions
# Post-install steps:
#   * Use `sudo passwd [username]` to set passwords for each user
#   * Use 'sudo smbpasswd -a [username]' to set passwords for each user
#   * If starting fresh gitolite repo: set the adminPubkey gitolite setting
#   * Set the permissions on Caddy's SSL certificate storage with
#     `sudo chmod -R g+rX /var/lib/caddy`
#   * Create directories in the data partition for each service
#
# TODO:
#   * Enable Firewall
#   * Avoid the Caddy permissions change; switch to services.acme for
#     provisioning Let's Encrypt certs, since it has user/group params?

{ config, pkgs, ... }:

let
  shareDir = "/mnt/data/share";
  servicesDir = "/mnt/data/services";
  sslCertificatesDir = "/var/lib/caddy/.caddy/acme/acme-v01.api.letsencrypt.org/sites";
in
{
  # Configuration submodules
  imports =
    [
      ../server.nix
      ./radicale-configuration.nix
    ];

  # Configuration for submodules
  pshendry = {
    radicale = {
      sslCertPath = sslCertificatesDir + "/home.pshendry.com/home.pshendry.com.crt";
      sslKeyPath = sslCertificatesDir + "/home.pshendry.com/home.pshendry.com.key";
      dataDir = servicesDir + "/radicale";
    };
  };

  # Boot
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Filesystems
  fileSystems = {
    "/" = pkgs.lib.mkForce {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };
    "/mnt/data" = {
      device = "/dev/disk/by-label/data";
      fsType = "ext4";
    };
  };
  swapDevices = pkgs.lib.mkForce [ { device = "/dev/disk/by-label/swap"; } ];

  # Networking
  networking = {
    hostName = "psh-server";
    firewall.enable = false;
  };

  # Users
  users.extraUsers = {
    pshendry.hashedPassword = "$6$I29u6yPCbyZSoaA$eq80uPlFhIylJaUE6pFlL6dBgoUiF.LK3CElIJUanXex3RXmeQXbrSS3qoMqs/J4YvhmAHp4RDQFVqE25p7t.0";
    ecmccutc = {
      uid = 1001;
      description = "Emma McCutcheon";
      hashedPassword = "$6$OEqLtIC1uaBktL$7H8sNgUVMN8LiT2Wl9iCTE27ZDeyd4AZof65kUvcAiCZDKxUbAX3jAKYR.uCQpg8pCGaqUzSWG50kzBpBIv0F1";
      isNormalUser = true;
    };
    mediapc = {
      uid = 1002;
      description = "Media PC";
      hashedPassword = "$6$UZ3v9h0GT$D4zKMueRE3XQ9tkz3TNdFQAFL5H0IDt/XBsQmO/yXiFVwBUFmGkPU96IbPnduj/h86v1/Bqebj7/tll/LeyWb.";
    };
    rpi2 = {
      uid = 1003;
      description = "Raspberry Pi 2";
      hashedPassword = "$6$ozs9JFcbQcmrsHA$ZM6j9KE6BAb6bcshTwG.H5uSJ4lWIw8wULFYgPTPZcArQdXykPMT/WM3GhrbzsXTLIyjdOXKLcfB9BZn3dOWe/";
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    caddy
  ];

  # Services
  services.samba = {
    enable = true;
    shares = {
      psh-share = {
        path = shareDir;
        browseable = "yes";
        "guest ok" = "no";
        "valid users" = "pshendry, ecmccutc, mediapc, rpi2";
        "read only" = "no";
      };
    };
  };

  services.gitolite = {
    enable = true;
    dataDir = servicesDir + "/gitolite";
    user = "git";
    adminPubkey = "";
  };

  services.syncthing = {
    enable = true;
    dataDir = servicesDir + "/syncthing";
    systemService = true;
  };

  services.caddy = {
    enable = true;
    agree = true;
    config = ''
      home.pshendry.com {
        root ${servicesDir}/www/home.pshendry.com
        gzip
      }
    '';
    email = "paul@pshendry.com";
  };

  services.unifi.enable = true;

  services.fail2ban.enable = true;
}
