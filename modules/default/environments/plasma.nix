{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (config.foxflake.environment.enable && config.foxflake.environment.type == "plasma") {
    services = {
      desktopManager.plasma6.enable = mkDefault true;
      displayManager = {
        sddm = {
          enable = mkDefault true;
          theme = mkDefault "breeze";
        };
        defaultSession = mkDefault "plasma";
      };
    };

    xdg.portal = {
      enable = mkDefault true;
      extraPortals = mkDefault [ pkgs.kdePackages.xdg-desktop-portal-kde ];
      xdgOpenUsePortal = mkDefault true;
    };

    systemd = {
      user.services.plasma-taskbar-icon-fix = {
        description = "Fix plasma taskbar icon path";
        before = [ "plasma-plasmashell.service" ];
        wantedBy = [ "plasma-core.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.writeShellScriptBin "plasma-taskbar-icon-fix" ''
            #!${pkgs.bash}
            if [ -f ''${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc ]; then
              ${pkgs.gnused}/bin/sed -i 's/file:\/\/\/nix\/store\/[^\/]*\/share\/applications\//applications:/gi' ''${HOME}/.config/plasma-org.kde.plasma.desktop-appletsrc
            fi
          ''}/bin/plasma-taskbar-icon-fix";
        };
        restartIfChanged = false;
      };
    };

    environment = {
      etc."xdg/baloofilerc" = {
        mode = "0644";
        text = ''
          [Basic Settings]
          Indexing-Enabled=false
        '';
      };
      plasma6.excludePackages = with pkgs; [
        kdePackages.plasma-browser-integration
        kdePackages.oxygen
      ];
      systemPackages = [
        pkgs.unstable.tela-circle-icon-theme

        (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
          [General]
          background="${config.foxflake.customization.environment.wallpaper}"
        '')
      ];
    };
    programs = {
      kdeconnect.enable = mkDefault true;
      partition-manager.enable = mkDefault true;
    };
  };

}
