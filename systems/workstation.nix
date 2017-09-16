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
    pulseaudio.enable = true;
  };
  powerManagement.enable = true;

  # Networking and firewall
  networking = {
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
    libav  # For Video DownloadHelper in Firefox
    okular
    vlc

    # Office
    kontact
    libreoffice-fresh
    # skanlite  # Doesn't exist yet
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

