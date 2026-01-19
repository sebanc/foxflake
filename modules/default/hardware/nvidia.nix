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
      description = "Whether to enable the Nvidia open source kernel driver. (Deprecated: All configs now use the open driver by default.)";
      type = with types; bool;
      default = true;
    };
  };

  config = mkIf config.foxflake.nvidia.enable {

    boot.blacklistedKernelModules = [ "nouveau" "nova_core" ];

    hardware.nvidia = {
      package = mkDefault config.boot.kernelPackages.nvidiaPackages.stable;
      open = mkDefault true;
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

    environment.variables = {
      __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
    };

    programs.nix-ld.libraries = with pkgs; [ linuxPackages.nvidia_x11 ];
  };

}
