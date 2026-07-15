{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "input-remapper" config.foxflake.system.applications) {

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
