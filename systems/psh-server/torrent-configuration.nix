{ config, lib, ... }:

with lib;

let
  cfg = config.pshendry.torrent;
in
{
  options = {
    pshendry.torrent = {
      sslCertPath = mkOption {
        type = types.path;
      };

      sslKeyPath = mkOption {
        type = types.path;
      };

      dataDir = mkOption {
	type = types.path;
      };
    };
  };

  config = {
    services.transmission = {
      enable = true;
      settings = {
        # Bandwidth
        alt-speed-up = 20;
        alt-speed-down = 1000;
  
        # Blocklists
        blocklist-enabled = true;
        blocklist-url = "http://list.iblocklist.com/?list=gyisgnzbhppbvsphucsw&fileformat=p2p&archiveformat=gz";
  
        # Files and locations
        download-dir = cfg.dataDir + "/complete";
        incomplete-dir-enabled = true;
        incomplete-dir = cfg.dataDir + "/downloading";
        trash-original-torrent-files = true;
        umask = 0;
        watch-dir-enabled = true;
        watch-dir = cfg.dataDir + "/watch";
  
        # Misc
        message-level = 1;
  
        # Queueing
        seed-queue-enabled = true;
  
        # RPC
        rpc-authentication-required = true;
        rpc-username = "pshendry";
        rpc-password = "{36aa6f2911661ad14aea5f38a87dc243b01e5a41qwXpJV4d";
        rpc-whitelist-enabled = false;
  
        # Scheduling
        alt-speed-time-enabled = true;
        alt-speed-time-begin = 480;
        alt-speed-time-end = 1439;
        ratio-limit-enabled = true;
        ratio-limit = 2;
      };
    };
  };
}
