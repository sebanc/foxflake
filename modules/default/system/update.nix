{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{
  options.foxflake.autoUpgrade = mkOption {
    description = "Enable FoxFlake automatic updates.";
    type = types.bool;
    default = true;
  };

  config = mkIf config.foxflake.autoUpgrade {

    system.autoUpgrade = {
      enable = mkDefault true;
      dates = mkDefault "daily";
      operation = mkDefault "boot";
      allowReboot = mkDefault false;
      flake = "/etc/nixos#foxflake";
      flags = [ "--update-input" "foxflake" "--commit-lock-file" ];
    };
  };

}
