{ user, ... }: { lib, pkgs, osConfig, ... }:
with lib;

{

  config = mkIf osConfig.services.flatpak.enable {
    services.flatpak = {
      remotes = mkDefault [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
      ];
      packages = mkDefault osConfig.foxflake.users."${user}".flatpaks;
      update.auto = {
        enable = mkDefault true;
        onCalendar = mkDefault "daily";
      };
    };
  };

}
