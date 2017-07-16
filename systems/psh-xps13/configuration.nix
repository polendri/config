# NixOS configuration for psh-xps13
#
# Install process:
#   * Disk setup
#       * Wipe the disk with pseudorandom data
#             dd if=/dev/urandom of=/dev/nvme0n1 bs=4096
#       * Partition disk using cgdisk
#           1. 512MB EFI partition with partition label "EFI" (hex code ef00)
#           2. Remaining with partition label "ROOT" (hex code 8300)
#       * Create LUKS volume
#             cryptsetup luksFormat /dev/disk/by-partlabel/ROOT
#       * Format partitions
#             mkfs.fat /dev/disk/by-partlabel/EFI
#             mkfs.ext4 /dev/mapper/root
#   * Installation
#       * Mount filesystems
#             cryptsetup luksOpen /dev/disk/by-partlabel/ROOT root
#             mount /dev/mapper/root /mnt
#             mkdir /mnt/boot
#             mount /dev/disk/by-partlabel/EFI /mnt/boot
#       * Generate base configuration
#             nixos-generate-config --root /mnt
#       * Copy this config to /mnt/etc/nixos
#       * Apply the configuration
#             nixos-install
#             reboot

{ config, pkgs, ... }:

{
  # Configuration submodules
  imports =
    [
      /etc/nixos/hardware-configuration.nix
    ];

  # NixOS
  system.stateVersion = "17.09";
  nixpkgs.config.allowUnfree = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Boot and filesystems
  boot = {
    cleanTmpDir = true;
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
    kernelPackages = pkgs.linuxPackages_latest;
  };
  fileSystems."/".options = [ "noatime" "nodiratime" ];

  # Hardware
  hardware = {
    bluetooth.enable = true;
    pulseaudio.enable = true;
    cpu.intel.updateMicrocode = true;
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };
  };
  powerManagement.enable = true;

  # Networking and firewall
  networking = {
    firewall = {
      allowPing = true;
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
    };
    hostName = "psh-xps13";
    networkmanager.enable = true;
  };

  # Localization and console
  i18n = {
    defaultLocale = "en_CA.UTF-8";
  };
  time.timeZone = "America/Vancouver";
  fonts.enableDefaultFonts = true;

  # Users
  users = {
    mutableUsers = false;
    groups = {
      guest = {};
    };
    users = {
      pshendry = {
        description = "Paul Hendry";
        extraGroups = [ "wheel" "networkmanager" "docker" ];
        hashedPassword = "$6$36L2gVyWVe$cIN7ZWX4ekceU.JMMnvThhmVq.PaB6PtOKl4Ec3N/1OOcVGQfND.8cpFjrRa2BEK/hEdBAw6gqHUckYpsnOV00";
        isNormalUser = true;
        uid = 1000;
      };
      guest = {
        createHome = true;
        description = "Guest User";
        group = "guest";
        home = "/tmp/home/guest";
        password = "";
        uid = 1001;
      };
    };
  };

  # Services
  services = {
    syncthing = {
      enable = true;
      dataDir = "/home/pshendry/.local/share/syncthing";
      openDefaultPorts = true;
      useInotify = true;
      user = "pshendry";
      group = "users";
    };

    xserver = {
      enable = true;
      desktopManager.plasma5.enable = true;
      displayManager.sddm = {
        enable = true;
        autoLogin = {
          enable = true;
          user = "pshendry";
        };
      };
      synaptics = {
        enable = true;
        horizEdgeScroll = false;
        horizTwoFingerScroll = true;
        palmDetect = true;
        twoFingerScroll = true;
        vertEdgeScroll = false;
        vertTwoFingerScroll = true;
      };
    };
  };
  virtualisation.docker.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    ag
    ark
    curl
    deluge
    discord
    docker_compose
    firefox
    gimp
    git
    kate
    kdeconnect
    lm_sensors
    nox
    okular
    nodePackages.node2nix
    python3
    python3Packages.pylint
    qsyncthingtray
    steam
    tmux
    unetbootin
    unzip
    vim
    vlc
    vscode
    wget
    zip
  ];

}
