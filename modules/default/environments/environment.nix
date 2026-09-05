{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  imports = [
    ../../../packages/foxflake-icons
    ../../../packages/foxflake-wallpapers
  ];

  options.foxflake.environment = {
    enable = mkOption {
      type = with types; bool;
      default = true;
      description = "Enable desktop environment.";
    };
    type = mkOption {
      type = with types; enum [ "cosmic" "custom" "gnome" "hyprland" "plasma" "steam" "steamdeck" ];
      default = "gnome";
      description = "Desktop environment selection.";
    };
    autologin = mkOption {
      type = with types; bool;
      default = !(config.foxflake.environment.autologinUser == null || config.foxflake.environment.autologinUser == "");
      description = "Enable desktop environment autologin.";
    };
    autologinUser = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "User chosen for desktop environment autologin.";
    };
  };

  config = mkIf (config.foxflake.environment.enable) {
    
    environment.systemPackages = with pkgs; [ foxflake-icons foxflake-wallpapers iio-sensor-proxy mesa-demos vulkan-tools xdg-user-dirs xdg-user-dirs-gtk ];

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
      "desktop-icons-fix" = {
        description = "Fix desktop icons path";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "desktop-icons-fix" ''
            #!${pkgs.bash}

            # Fix for desktop icons links
            for desktopicon in "$(${pkgs.xdg-user-dirs}/bin/xdg-user-dir DESKTOP)"/*.desktop; do
              if [ -L "''${desktopicon}" ] && [[ "$(readlink "''${desktopicon}")" =~ ^/nix/store/[^/]*/share/applications(/.*)?$ ]]; then
                ln -sfn "/run/current-system/sw/share/applications/$(basename "''${desktopicon}")" "''${desktopicon}"
              fi
            done
          ''}/bin/desktop-icons-fix";
        };
        restartIfChanged = false;
      };
      "xdg-user-dirs-update" = {
        description = "Update XDG user directories";
        wantedBy = [ "default.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.xdg-user-dirs}/bin/xdg-user-dirs-update";
        };
        restartIfChanged = false;
      };
      "xdg-user-dirs-gtk-update" = {
        description = "Update XDG user directories (GTK)";
        wantedBy = [ "graphical-session.target" ];
        after = [ "xdg-user-dirs-update.service" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.xdg-user-dirs-gtk}/bin/xdg-user-dirs-gtk-update";
        };
        restartIfChanged = false;
      };
    };

  };

}
