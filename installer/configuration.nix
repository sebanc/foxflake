{ config, lib, pkgs, ... }:

{
  foxflake.environment.type = "gnome";
  foxflake.system.bundles = [ ];
  foxflake.autoUpgrade = false;
  foxflake.environment.switching.enable = false;
  specialisation = {
    nvidia = {
      configuration = {
        system.nixos.tags = lib.mkForce [ "nvidia_driver" ];
        foxflake.nvidia.enable = true;
      };
    };
  };

  networking.hostName = "foxflake";
}
