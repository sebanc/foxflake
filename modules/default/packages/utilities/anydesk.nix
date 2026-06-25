{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "anydesk" config.foxflake.system.applications) {

    environment.systemPackages = [
      (pkgs.stable.anydesk.overrideAttrs (old: rec {
        version = "8.0.3";
        src = pkgs.stable.fetchurl {
          url = "https://download.anydesk.com/linux/anydesk-${version}-amd64.tar.gz";
          hash = "sha256-Mjl17hh5A/pwRAi7giL1SJYlQ61O0SXX+KeH8STZ4bs=";
        };
      }))
    ];

  };

}
