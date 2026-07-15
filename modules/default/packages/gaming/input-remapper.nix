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
        input-remapper = (prev.input-remapper.override {
          python3Packages = prev.python313Packages;
        }).overridePythonAttrs (old: {
          propagatedBuildInputs = (old.propagatedBuildInputs or [ ]) ++ [
            prev.python313Packages.packaging
            prev.python313Packages.setuptools
          ];
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
