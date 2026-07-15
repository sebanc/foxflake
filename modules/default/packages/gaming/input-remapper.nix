{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "input-remapper" config.foxflake.system.applications) {

    nixpkgs.overlays = [
      (final: prev: {
        input-remapper = prev.input-remapper.overridePythonAttrs (oldAttrs: {
          dependencies = map (pkg:
            if pkg.pname or "" == "setuptools"
            then final.python3Packages.setuptools_80
            else pkg
          ) oldAttrs.dependencies;
        });
      })
    ];

    services.input-remapper = {
      enable = mkDefault true;
      enableUdevRules = mkDefault true;
    };
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.policykit.exec" && action.lookup("program") == "${pkgs.input-remapper}/bin/input-remapper-control" && subject.isInGroup("users")) {
          return polkit.Result.YES;
        }
      });
    '';

  };

}
