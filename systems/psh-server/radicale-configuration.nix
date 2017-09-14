{ config, lib, ... }:

with lib;

let
  cfg = config.pshendry.radicale;
in
{
  options = {
    pshendry.radicale = {
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
    users.extraUsers = {
      radicale = {
        # Add group to permit radicale to read the SSL cert/key
        extraGroups = ["caddy"];
      };
    };
  
    services.radicale = {
      enable = true;
      config = ''
        [server]
  
        # SSL flag, enable HTTPS protocol
        ssl = True
        
        # SSL certificate path
        certificate = ${cfg.sslCertPath}
        
        # SSL private key
        key = ${cfg.sslKeyPath}
        
        # Root URL of Radicale (starting and ending with a slash)
        base_prefix = /
        
        [auth]
        
        # Authentication method
        # Value: None | htpasswd | IMAP | LDAP | PAM | courier | http | remote_user | custom
        type = htpasswd
        
        # Htpasswd filename
        htpasswd_filename = /etc/radicale/users
  
        # Htpasswd encryption method
        # Value: plain | sha1 | ssha | crypt | bcrypt | md5
        htpasswd_encryption = bcrypt
        
        
        [rights]
        
        # Rights backend
        # Value: None | authenticated | owner_only | owner_write | from_file | custom
        type = from_file
  
        # File for rights management from_file
        file = /etc/radicale/rights
        
        
        [storage]
        
        # Folder for storing local collections, created if not present
        filesystem_folder = ${cfg.dataDir}
        
        
        [logging]
        
        # Logging configuration file
        # If no config is given, simple information is printed on the standard output
        # For more information about the syntax of the configuration file, see:
        # http://docs.python.org/library/logging.config.html
        config = /etc/radicale/logging
        # Set the default logging level to debug
        debug = True
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
          collection: ^%(login)s/.*$
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
  
      radicaleLogging = {
        target = "radicale/logging";
        mode = "0644";
        text = ''
          [loggers]
          keys = root
  
          [handlers]
          keys = console,file
  
          [formatters]
          keys = simple,full
  
          # Loggers
  
          [logger_root]
          level = WARNING
          handlers = console,file
  
          # Handlers
  
          [handler_console]
          class = StreamHandler
          level = WARNING
          args = (sys.stdout,)
          formatter = simple
  
          [handler_file]
          class = FileHandler
          args = ('/var/log/radicale',)
          formatter = full
  
          # Formatters
  
          [formatter_simple]
          format = %(message)s
  
          [formatter_full]
          format = %(asctime)s - %(levelname)s: %(message)s
        '';
      };
    };

    # Hack to provide passlib to radicale, so that bcrypt password hashing can be used
    nixpkgs.config.packageOverrides = pkgs: {
      radicale = pkgs.radicale.overrideAttrs (oldAttrs: {
        propagatedBuildInputs = (oldAttrs.propagatedBuildInputs or []) ++ [ pkgs.pythonPackages.passlib ];
      });
    };
  };
}
