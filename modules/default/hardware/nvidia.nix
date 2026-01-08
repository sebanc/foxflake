{ lib, config, pkgs, ... }:
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

    boot.blacklistedKernelModules = [ "nouveau" "nova_core" ];

    hardware.nvidia = {
      package = mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
      open = mkDefault config.foxflake.nvidia.open;
      modesetting.enable = mkDefault true;
      nvidiaSettings = mkDefault true;
    };

    services.xserver.videoDrivers = mkDefault [ "nvidia" ];

    systemd.services.nvidia-suspend.enable = mkDefault true;
    systemd.services.nvidia-resume.enable = mkDefault true;
    systemd.services.nvidia-hibernate.enable = mkDefault true;
    systemd.shutdown."nvidia.shutdown" = pkgs.writeScript "nvidia.shutdown" ''
      #!/bin/sh
      for MODULE in nvidia_drm nvidia_modeset nvidia_uvm nvidia; do
        if lsmod | grep "''${MODULE}" &> /dev/null; then rmmod ''${MODULE}; fi
      done
    '';

    programs.nix-ld.libraries = with pkgs; [ linuxPackages.nvidia_x11 ];

    nixpkgs.config.cudaSupport = mkDefault true;
    nixpkgs.config.rocmSupport = mkOverride 999 false;
  };

}
