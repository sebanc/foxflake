{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = {

    services.qemuGuest.enable = mkDefault true;
    services.spice-vdagentd.enable = mkDefault true;

  };

}
