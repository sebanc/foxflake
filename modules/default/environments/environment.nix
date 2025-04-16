{ config, lib, pkgs, ... }:
with lib;

let
  foxflake-environment-selection = pkgs.callPackage ../../../packages/foxflake-environment-selection {};
in
{
  options.foxflake.environment = {
    enable = mkOption {
      type = with types; bool;
      default = true;
      description = "Enable desktop environment";
    };
    type = mkOption {
      description = "Desktop environment selection";
      type = with types; enum [ "gnome" "plasma" ];
      default = "gnome";
    };
    autologin = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable desktop environment autologin";
    };
    autologinUser = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "User chosen for desktop environment autologin";
    };
    switching.enable = mkOption {
      description = "Enable environment and bundles switching program";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.foxflake.environment.enable {
    
    environment.systemPackages = if (config.foxflake.environment.switching.enable) then
      with pkgs; [ foxflake-environment-selection zenity ]
    else
      [ ];
    
    hardware.bluetooth.enable = mkDefault true;
    networking.networkmanager.enable = mkDefault true;

    services = {
      displayManager.autoLogin = {
        enable = mkDefault config.foxflake.environment.autologin;
        user = mkDefault config.foxflake.environment.autologinUser;
      };
      xserver = {
        enable = mkDefault true;
        excludePackages = mkDefault [ pkgs.xterm ];
        xkb = {
          layout = mkDefault config.foxflake.internationalisation.keyboard.layout;
          variant = mkDefault config.foxflake.internationalisation.keyboard.variant;
        };
      };
    };
  };

}
