{ config, pkgs, lib, ... }:

let
  cfg = config.pshendry.radicale;
in
{
  options = {
    pshendry.radicale = {
      sslCertPath = lib.mkOption {
        type = lib.types.path;
      };

      sslKeyPath = lib.mkOption {
        type = lib.types.path;
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
      };
    };
  };

  config = {
    users.extraUsers = {
      radicale = {
        # Add group to permit radicale to read the SSL cert/key
        extraGroups = ["caddy"];
      };
    };
  
    services.radicale = {
      enable = true;
      package = pkgs.radicale2;
      config = ''
        [server]
        hosts = 0.0.0.0:5232
        ssl = True
        certificate = ${cfg.sslCertPath}
        key = ${cfg.sslKeyPath}
        
        [auth]
        type = htpasswd
        htpasswd_filename = /etc/radicale/users
        htpasswd_encryption = bcrypt
        
        [rights]
        type = from_file
        file = /etc/radicale/rights
        
        [storage]
        filesystem_folder = ${cfg.dataDir}
      '';
    };
  
    environment.etc = {
      radicaleUsers = {
        target = "radicale/users";
        mode = "0640";
        gid = config.ids.gids.radicale;
        text = ''
          pshendry:$2y$05$hIGxVRZBpD3dkl9kGsYtN.jXjei8ffrLlULrpmcMsFJJvqSQdD0lq
          ecmccutc:$2y$05$J1yf7IXIf1.P4QZl4k0y6OF.HdtQdZWkbNR8JA6/e3mp9CSBDlXzy
        '';
      };
  
      radicaleRights = {
        target = "radicale/rights";
        mode = "0644";
        text = ''
          [owner-readwrite]
          user: .+
          collection: ^%(login)s(/.*)?$
          permission: rw
  
          [everyone-shared-readwrite]
          user: .+
          collection: ^.+/shared-.*$
          permission: rw
  
          [everyone-read]
          user: .+
          collection: .*
          permission: r
        '';
      };
    };
  };
}
