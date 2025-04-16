{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.system = {
    bundles = mkOption {
      description = "bundles selection";
      type = with types; listOf str;
      default = [ "standard" ];
    };
    packages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [ ];
      example = literalExpression "with pkgs; [ firefox ]";
      description = ''
        The set of packages that should be made available to all users.
      '';
    };
    flatpaks = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = literalExpression "[ { appId = \"org.mozilla.firefox\"; origin = \"flathub\"; } ]";
      description = ''
        The set of packages that should be installed as flatpak.
      '';
    };
    waydroid = mkOption {
      type = with types; bool;
      default = false;
      description = ''
        The Waydroid application that allows you to use Android apps on your computer.
      '';
    };
  };

  config = {
  
    environment.systemPackages = config.foxflake.system.packages;

    programs.appimage = {
      enable = mkDefault true;
      binfmt = mkDefault true;
    };

    services.flatpak = {
      enable = true;
      remotes = [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
      ];
      packages = config.foxflake.system.flatpaks;
    };

    systemd = {
      services.system-flatpak-updates = {
        description = "Update system flatpaks";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.flatpak}/bin/flatpak update --assumeyes --noninteractive";
        };
        wantedBy = [ "multi-user.target" ];
        startAt = "daily";
      };
      user.services.user-flatpak-updates = {
        description = "Update user flatpaks";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.flatpak}/bin/flatpak update --assumeyes --noninteractive --system";
        };
        wantedBy = [ "default.target" ];
        startAt = "daily";
      };
    };
  };

}
