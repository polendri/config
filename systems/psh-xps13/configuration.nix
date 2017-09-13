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
  system.stateVersion = "18.03";
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
      allowedTCPPorts = [
        445  # Samba
      ];
      allowedTCPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
        { from = 137;  to = 139; }   # Samba
      ];
      allowedUDPPortRanges = [
        { from = 1714; to = 1764; }  # KDE Connect
      ];
      autoLoadConntrackHelpers = true;
      connectionTrackingModules = [ "netbios_ns" ];
      extraCommands = ''
        iptables -t raw -A OUTPUT -d 192.168.0.0/16 -p udp -m udp --dport 137 -j CT --helper netbios-ns
      '';
      extraStopCommands = ''
        iptables -t raw -D OUTPUT -d 192.168.0.0/16 -p udp -m udp --dport 137 -j CT --helper netbios-ns
      '';
    };
    hostName = "psh-xps13";
    nameservers = [
      "209.222.18.222"  # PIA nameservers
      "209.222.18.218"  #
    ];
    networkmanager.enable = true;
  };

  # Key managemnet
  programs.ssh = {
    agentTimeout = "30m";
    startAgent = true;
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
        extraGroups = [ "wheel" "networkmanager" "docker" "plugdev" "vboxusers" ];
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

  # Configuration files
  environment.etc = {
    pia_crt = {
      source = ./pia/ca.rsa.2048.crt;
      target = "pia/ca.rsa.2048.crt";
    };
    pia_pem = {
      source = ./pia/crl.rsa.2048.pem;
      target = "pia/crl.rsa.2048.pem";
    };
    pia_credentials = {
      source = ./secrets/pia_credentials.txt;
      target = "pia/credentials.txt";
      mode = "0600";
    };
  };

  # Services
  services = {
    openvpn.servers = {
      pia = {
        autoStart = false;
        config = ''
          client
          dev tun0
          proto udp
          remote us-seattle.privateinternetaccess.com 1198
          resolv-retry infinite
          nobind
          persist-key
          persist-tun
          cipher aes-128-cbc
          auth sha1
          tls-client
          remote-cert-tls server
          auth-user-pass /etc/pia/credentials.txt
          comp-lzo
          verb 1
          reneg-sec 0
          crl-verify /etc/pia/crl.rsa.2048.pem
          ca /etc/pia/ca.rsa.2048.crt
          disable-occ
        '';
      };
    };

    redshift = {
      enable = true;
      latitude = "48.4284";
      longitude = "-123.3656";
    };

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
  virtualisation = {
    docker.enable = true;
    virtualbox.host = {
      enable = true;
      addNetworkInterface = true;
    };
  };
  # Enables more VirtualBox features, but requires compilation of VirtualBox which takes ages...
  # Maybe with distributed builds enabled this will be do-able?
  # nixpkgs.config.virtualbox.enableExtensionPack = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Gaming
    (steam.override { newStdcpp = true; })  # See https://github.com/NixOS/nixpkgs/issues/25957

    # Internet
    chromium
    deluge
    discord
    firefox
    konversation

    # Multimedia
    audaciousQt5
    audacity
    digikam
    ffmpeg
    gimp
    inkscape
    krita
    libav
    okular
    vlc
    zoom-us

    # Office
    kontact
    libreoffice-fresh
    # skanlite  # Doesn't exist yet
    texlive.combined.scheme-basic

    # Software Development
    androidsdk
    android-studio-preview
    docker_compose
    git
    nixops
    python3
    python3Packages.pylint
    vscode

    # Utilities
    ag
    ark
    curl
    homebank
    iftop
    iotop
    kate
    kcalc
    kdeconnect
    keepassx2
    krename
    lm_sensors
    nox
    ntfs3g
    partition-manager
    qsyncthingtray
    rsync
    spectacle
    tmux
    traceroute
    unetbootin
    unzip
    vim
    wget
    wireshark
    zip
  ];

}
