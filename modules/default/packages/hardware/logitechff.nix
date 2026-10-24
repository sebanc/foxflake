{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "logitechff" config.foxflake.system.applications) {

    boot = {
      extraModulePackages = [ (config.boot.kernelPackages.new-lg4ff.override (oldAttrs: { kernelModuleMakeFlags = map lib.escapeShellArg oldAttrs.kernelModuleMakeFlags; })) ];
      kernelModules = [ "hid-logitech-new" ];
    };

  };

}
