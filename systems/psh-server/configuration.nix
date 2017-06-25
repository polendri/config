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
#   * Review radicale configuration
#   * Avoid the Caddy permissions change; switch to services.acme for
#     provisioning Let's Encrypt certs, since it has user/group params?

{ config, pkgs, ... }:

let
  dataDir = "/mnt/data";
  servicesDir = "/mnt/data/services";
  sslCertificatesDir = "/var/lib/caddy/.caddy/acme/acme-v01.api.letsencrypt.org/sites";
in
{
  # Configuration submodules
  imports =
    [
      /etc/nixos/hardware-configuration.nix
      ./radicale-configuration.nix
      ./torrent-configuration.nix
    ];

  # Configuration for submodules
  pshendry = {
    radicale = {
      sslCertPath = sslCertificatesDir + "/home.pshendry.com/home.pshendry.com.crt";
      sslKeyPath = sslCertificatesDir + "/home.pshendry.com/home.pshendry.com.key";
      dataDir = servicesDir + "/radicale";
    };
    torrent.dataDir = servicesDir + "/torrents";
  };

  # NixOS configuration
  system.stateVersion = "17.03";
  nixpkgs.config.allowUnfree = true;

  # Boot
  boot.loader = {
    systemd-boot.enable = true;
    timeout = null;
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

  # Internationalisation properties
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Time zone
  time.timeZone = "America/Vancouver";

  # Nix store garbage collection
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # User accounts.
  users.extraUsers = {
    pshendry = {
      uid = 1000;
      isNormalUser = true;
      description = "Paul Hendry";
      extraGroups = [ "wheel" "lpadmin" ];
    };
    ecmccutc = {
      uid = 1001;
      isNormalUser = true;
      description = "Emma McCutcheon";
    };
    mediapc = {
      uid = 1002;
      description = "Media PC";
    };
  };

  # Packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bash
    caddy
    tmux
    wget
    vim
    zip
  ];

  # Services
  services = {
    openssh = {
      enable = true;
      permitRootLogin = "no";
    };

    samba = {
      enable = true;
      shares = {
        psh-share = {
          path = dataDir;
          browseable = "yes";
          "guest ok" = "no";
          "valid users" = "pshendry, ecmccutc, mediapc";
          "read only" = "no";
        };
      };
    };
  
    gitolite = {
      enable = true;
      dataDir = servicesDir + "/gitolite";
      user = "git";
      adminPubkey = "";
    };
  
    syncthing = {
      enable = true;
      dataDir = servicesDir + "/syncthing";
      systemService = true;
    };

    caddy = {
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

    unifi = {
      enable = true;
    };
  };
}
