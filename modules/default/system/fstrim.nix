{ lib, config, ... }:
with lib;

{

  options.foxflake.fstrim.enable = mkOption {
    description = "Enable FoxFlake Fstrim configurations";
    type = types.bool;
    default = true;
  };

  config = mkIf config.foxflake.fstrim.enable {

    services.fstrim = {
      enable = mkDefault true;
      interval = mkDefault "daily";
    };

  };

}
