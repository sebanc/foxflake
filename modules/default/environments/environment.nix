{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.environment = {
    enable = mkOption {
      type = with types; bool;
      default = true;
      description = "Enable desktop environment";
    };
    type = mkOption {
      description = "Desktop environment selection";
      type = with types; enum [ "cosmic" "gnome" "hyprland" "plasma" ];
      default = "gnome";
    };
    autologin = mkOption {
      type = with types; bool;
      default = !(config.foxflake.environment.autologinUser == null || config.foxflake.environment.autologinUser == "");
      description = "Enable desktop environment autologin";
    };
    autologinUser = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "User chosen for desktop environment autologin";
    };
    selection.enable = mkOption {
      description = "Enable environment and applications switching program";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf config.foxflake.environment.enable {
    
    environment.systemPackages = with pkgs; [ iio-sensor-proxy xdg-user-dirs xdg-user-dirs-gtk foxflake-icons foxflake-wallpapers ];

    hardware.bluetooth.enable = mkDefault true;
    hardware.sensor.iio.enable = mkDefault true;
    networking.networkmanager = {
      enable = mkDefault true;
      plugins = with pkgs; [ networkmanager-openvpn ];
    };
    services.resolved.enable = mkDefault true;

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

    systemd.user.services = {
      xdg-user-dirs-update = {
        description = "Update XDG user directories";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update";
        };
        restartIfChanged = false;
      };
      xdg-user-dirs-gtk-update = {
        description = "Update XDG user directories (GTK)";
        wantedBy = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.xdg-user-dirs-gtk}/bin/xdg-user-dirs-gtk-update";
        };
        restartIfChanged = false;
      };
    };

  };

}
