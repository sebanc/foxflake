{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "winboat" config.foxflake.system.applications) {

    environment.systemPackages = [
      (pkgs.stable.winboat.override {
        electron_40 = pkgs.stable.electron_40.overrideAttrs (old: {
          meta = old.meta // { knownVulnerabilities = [ ]; insecure = false; };
        });
      })
    ];

  };

}
