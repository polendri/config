{ config, lib, ... }:

with lib;

{
  config = {
    users.extraUsers = {
      deluge = {
        # Add group to permit deluge to read the SSL cert/key
        extraGroups = ["caddy"];
      };
    };

    services.deluge = {
      enable = true;
      web.enable = true;
    };
  };
}
