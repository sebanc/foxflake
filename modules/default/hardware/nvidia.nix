{ lib, config, pkgs, ... }:
with lib;

{

  options.foxflake.nvidia = {
    enable = mkOption {
      type = with types; bool;
      default = false;
      description = "Enable nvidia support.";
    };
    open = mkOption {
      type = with types; bool;
      default = true;
      description = "DEPRECATED: The open driver is now used by default.";
    };
  };

  config = mkIf (config.foxflake.nvidia.enable) {

    boot.blacklistedKernelModules = [ "nouveau" "nova_core" ];

    hardware.nvidia = {
      package = mkDefault config.boot.kernelPackages.nvidiaPackages.new_feature;
      open = mkDefault true;
      modesetting.enable = mkDefault true;
      nvidiaSettings = mkDefault true;
    };

    services.xserver.videoDrivers = mkDefault [ "nvidia" ];

    systemd = {
      services = {
        "nvidia-suspend".enable = mkDefault true;
        "nvidia-resume".enable = mkDefault true;
        "nvidia-hibernate".enable = mkDefault true;
      };
      shutdown."nvidia-shutdown" = pkgs.writeShellScript "nvidia-shutdown.sh" ''
        # Dynamically unbind all VT consoles bound to a driver
        for vtcon in /sys/class/vtconsole/vtcon*; do
          if [ -f "$vtcon/bind" ] && [ "$(${pkgs.coreutils}/bin/cat "$vtcon/bind")" -eq 1 ]; then
            echo 0 > "$vtcon/bind" 2>/dev/null || true
          fi
        done

        # Recursively unload modules
        for MODULE in nvidia_drm nvidia_modeset nvidia_uvm nvidia; do
          if ${pkgs.kmod}/bin/lsmod | ${pkgs.gnugrep}/bin/grep "$MODULE" > /dev/null 2>&1; then
            ${pkgs.kmod}/bin/rmmod "$MODULE"
          fi
        done
      '';
    };

    environment.variables = {
      __GL_SHADER_DISK_CACHE_SIZE = "12000000000";
    };

    nixpkgs = {
      config = {
        nvidia.acceptLicense = true;
      };
      overlays = [(final: prev: {
        appimage-run-foxflake = prev.symlinkJoin {
          buildInputs = with final; [ makeWrapper ];
          meta.mainProgram = "appimage-run";
          name = "appimage-run";
          paths = [ prev.appimage-run-foxflake ];
          postBuild = ''
            wrapProgram $out/bin/appimage-run \
              --run '
                if [ -e /dev/nvidia0 ] && [ -f /run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json ] && [ ! "''${DISABLE_APPIMAGE_NVIDIA_FIX}" == "1" ]; then
                  echo "appimage-run: NVIDIA GPU detected, giving it priority. This behavior can be reverted by setting DISABLE_APPIMAGE_NVIDIA_FIX=1."
                  export VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json
                  export __GLX_VENDOR_LIBRARY_NAME=nvidia
                fi
              '
          '';
        };
      })];
    };

    programs.nix-ld.libraries = with pkgs; [ config.hardware.nvidia.package ] ++ optionals (config.foxflake.graphics.compute) (with pkgs; [ cudaPackages.cudnn cudaPackages.libcublas cudaPackages.libcusolver cudaPackages.libcusparse ]);

  };

}
