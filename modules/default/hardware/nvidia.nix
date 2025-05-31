{ config, lib, ... }:
with lib;

{

  options.foxflake.nvidia = {
    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable nvidia support";
    };
    open = mkOption {
      description = "Whether to enable the Nvidia open source kernel driver.";
      type = with types; bool;
      default = true;
    };
  };

  config = mkIf config.foxflake.nvidia.enable {

    boot.blacklistedKernelModules = [ "nouveau" ];

    hardware.nvidia = {
      package = mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
      open = mkDefault config.foxflake.nvidia.open;
      modesetting.enable = mkDefault true;
      nvidiaSettings = mkDefault true;
    };

    services.xserver.videoDrivers = mkDefault [ "nvidia" ];

  };

}
