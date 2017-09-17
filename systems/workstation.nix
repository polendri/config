# Common configuration for any GUI-based workstation.

{ config, pkgs, ... }:

{
  imports = [
    ./common.nix
  ];

  # Hardware
  hardware = {
    cpu.intel.updateMicrocode = true;
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
    };
    pulseaudio = {
      enable = true;
      support32Bit = true;
    };
    sane = {
      enable = true;
      extraBackends = with pkgs; [ hplip ];
    };
  };
  powerManagement.enable = true;

  # Networking and firewall
  networking = {
    firewall = {
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
    networkmanager.enable = true;
  };

  # Miscellaneous
  fonts.enableDefaultFonts = true;
  programs.ssh = {
    agentTimeout = "30m";
    startAgent = true;
  };

  # Users
  users = {
    groups = {
      guest = {};
    };
    users = {
      pshendry = {
        extraGroups = [ "wheel" "networkmanager" "docker" ];
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

  # Desktop environment
  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  # Services
  services.redshift = {
    enable = true;
    latitude = "48.4284";
    longitude = "-123.3656";
  };

  services.syncthing = {
    enable = true;
    dataDir = "/home/pshendry/.local/share/syncthing";
    openDefaultPorts = true;
    useInotify = true;
    user = "pshendry";
    group = "users";
  };

  virtualisation.docker.enable = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Gaming
    steam

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
    kodi
    krita
    libav  # For Video DownloadHelper in Firefox
    musescore
    okular
    vlc

    # Office
    kontact
    libreoffice-fresh
    simple-scan
    texlive.combined.scheme-basic

    # Software Development
    androidsdk
    android-studio-preview
    docker_compose
    nixops
    python3
    python3Packages.pylint
    vscode

    # Utilities
    ag
    ark
    homebank
    kate
    kcalc
    kdeconnect
    keepassx2
    krename
    lm_sensors
    ntfs3g
    partition-manager
    qsyncthingtray
    spectacle
    unetbootin
    wireshark
  ];
}

