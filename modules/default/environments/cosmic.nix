{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (config.foxflake.environment.enable && config.foxflake.environment.type == "cosmic") {

    services = {
      desktopManager.cosmic.enable = mkDefault true;
      displayManager.cosmic-greeter.enable = mkDefault true;
    };

    xdg.portal = {
      enable = mkDefault true;
      extraPortals = mkDefault [ pkgs.xdg-desktop-portal-cosmic ];
      xdgOpenUsePortal = mkDefault true;
    };

    environment.systemPackages = [
      pkgs.unstable.tela-circle-icon-theme
    ];

    systemd.user.services = {
      cosmic-defaults = {
        description = "Apply cosmic defaults";
        before = [ "graphical-session-pre.target" ];
        wantedBy = [ "graphical-session-pre.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "cosmic-defaults" ''
            #!${pkgs.bash}

            if [ ! -f "''${HOME}/.config/cosmic/com.system76.CosmicBackground/v1/all" ]; then
              mkdir -p "''${HOME}/.config/cosmic/com.system76.CosmicBackground/v1"
              cat >"''${HOME}/.config/cosmic/com.system76.CosmicBackground/v1/all" <<BACKGROUND
            (
                output: "all",
                source: Path("${config.foxflake.customization.environment.wallpaper}"),
                filter_by_theme: true,
                rotation_frequency: 3600,
                filter_method: Lanczos,
                scaling_mode: Zoom,
                sampling_method: Alphanumeric,
            )
            BACKGROUND
            fi

            if [ ! -f "''${HOME}/.config/cosmic/com.system76.CosmicTk/v1/icon_theme" ]; then
              mkdir -p "''${HOME}/.config/cosmic/com.system76.CosmicTk/v1"
              cat >"''${HOME}/.config/cosmic/com.system76.CosmicTk/v1/icon_theme" <<ICONTHEME
            "${config.foxflake.customization.environment.icon-theme}"
            ICONTHEME
            fi

            if [ ! -f "''${HOME}/.config/cosmic/com.system76.CosmicTk/v1/cursor_theme" ]; then
              mkdir -p "''${HOME}/.config/cosmic/com.system76.CosmicTk/v1"
              cat >"''${HOME}/.config/cosmic/com.system76.CosmicTk/v1/cursor_theme" <<CURSORTHEME
            "${config.foxflake.customization.environment.cursor-theme}"
            CURSORTHEME
            fi
          ''}/bin/cosmic-defaults";
        };
        restartIfChanged = false;
      };
    };

  };

}
