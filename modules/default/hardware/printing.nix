{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.printing = {
    enable = mkOption {
      type = types.bool;
      default = if (config.foxflake.environment.enable) then
        true
      else
        false;
      description = "Enable FoxFlake printing configurations.";
    };
  };

  config = mkIf (config.foxflake.printing.enable) {

    hardware.sane.enable = mkDefault true;
    services.avahi = {
      enable = mkDefault true;
      nssmdns4 = mkDefault true;
    };
    services.ipp-usb.enable = mkDefault true;
    services.printing = {
      enable = mkDefault true;
      drivers = with pkgs; [
        cups-filters
        cups-browsed
      ];
    };


  };

}
