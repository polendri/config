# NixOS configuration for psh-xps13
#
# Install process:
#   * Disk setup
#     * Wipe the disk with pseudorandom data
#         dd if=/dev/urandom of=/dev/nvme0n1 bs=4096
#     * Partition disk using cgdisk
#       1. 512MB EFI partition with partition label "EFI" (hex code ef00)
#       2. Remaining with partition label "ROOT" (hex code 8300)
#     * Create LUKS volume
#         cryptsetup luksFormat /dev/disk/by-partlabel/ROOT
#     * Format partitions
#         mkfs.fat /dev/disk/by-partlabel/EFI
#         mkfs.ext4 /dev/mapper/root
#   * Installation
#     * Mount filesystems
#         cryptsetup luksOpen /dev/disk/by-partlabel/ROOT root
#         mount /dev/mapper/root /mnt
#         mkdir /mnt/boot
#         mount /dev/disk/by-partlabel/EFI /mnt/boot
#     * Generate base configuration
#         nixos-generate-config --root /mnt
#     * Add git to the generated configuration, then apply it and reboot
#         nixos-install
#         reboot
#     * Clone git@github.com:pshendry/config into ~/Code/config
#     * Change /etc/nixos/configuration.nix to a single import of
#       /home/pshendry/Code/config/systems/psh-xps13/configuration.nix
#     * Run nixos-rebuild switch

{ config, pkgs, ... }:

{
  imports = [
    ../workstation.nix
  ];

  # Boot and filesystems
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 0;
    };
  };
  # Spare the SSD from writes to set access timestamps
  fileSystems."/".options = [ "noatime" "nodiratime" ];

  # Hardware
  hardware.bluetooth.enable = true;
  services.xserver.synaptics = {
    enable = true;
    horizEdgeScroll = false;
    horizTwoFingerScroll = true;
    palmDetect = true;
    twoFingerScroll = true;
    vertEdgeScroll = false;
    vertTwoFingerScroll = true;
  };

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
    hostName = "psh-xps13";
  };

  # Users
  users.users.pshendry = {
    extraGroups = [ "wheel" "networkmanager" "docker" "plugdev" "vboxusers" ];
    hashedPassword = "$6$36L2gVyWVe$cIN7ZWX4ekceU.JMMnvThhmVq.PaB6PtOKl4Ec3N/1OOcVGQfND.8cpFjrRa2BEK/hEdBAw6gqHUckYpsnOV00";
  };

  # Desktop environment
  services.xserver.displayManager.sddm.autoLogin = {
    enable = true;
    user = "pshendry";
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
  services.openvpn.servers = {
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

  services.printing = {
    enable = true;
    drivers = with pkgs; [ gutenprint ];
    webInterface = false;
  };
  virtualisation.virtualbox.host = {
    enable = true;
    addNetworkInterface = true;
  };
  # Enables more VirtualBox features, but requires compilation of VirtualBox which takes ages...
  # Maybe with distributed builds enabled this will be do-able?
  # nixpkgs.config.virtualbox.enableExtensionPack = true;

  # System packages
  environment.systemPackages = with pkgs; [
    # Internet
    zoom-us

    # Utilities
    kdeconnect
  ];

}
