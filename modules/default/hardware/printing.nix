{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.printing.enable = mkOption {
    description = "Enable FoxFlake printing configurations.";
    type = types.bool;
    default = true;
  };

  config = mkIf config.foxflake.printing.enable {

    hardware.sane.enable = mkDefault true;
    services.avahi.enable = mkDefault true;
    services.avahi.nssmdns4 = mkDefault true;
    services.printing.enable = mkDefault true;

    environment.systemPackages = if (builtins.elem "standard" config.foxflake.system.bundles) then with pkgs; [ simple-scan ] else [ ];

  };

}
