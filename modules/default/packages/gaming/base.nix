{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.gaming = {
    hdr = mkOption {
      type = with types; bool;
      default = false;
      example = "true";
      description = ''
        Whether to enable HDR in the Steam session.
      '';
    };
  };

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || config.foxflake.environment.type == "steam" || config.foxflake.environment.type == "steamdeck" || builtins.elem "gaming" config.foxflake.system.applications || builtins.elem "faugus" config.foxflake.system.applications || builtins.elem "goverlay" config.foxflake.system.applications || builtins.elem "heroic" config.foxflake.system.applications || builtins.elem "lutris" config.foxflake.system.applications || builtins.elem "mangojuice" config.foxflake.system.applications || builtins.elem "steam" config.foxflake.system.applications) {

    boot.kernel.sysctl = {
      "kernel.split_lock_mitigate" = mkOverride 999 0;
      "net.ipv4.tcp_slow_start_after_idle" = mkOverride 999 0;
      "net.ipv4.tcp_fastopen" = mkOverride 999 3;
      "vm.max_map_count" = mkOverride 999 2147483642;
      "vm.swappiness" = mkOverride 999 10;
    };

    environment = {
      systemPackages = with pkgs; [
        mangohud
        vkbasalt
      ];
      variables = { }
        // lib.optionalAttrs (config.foxflake.gaming.hdr) { DXVK_HDR = 1; }
        // lib.optionalAttrs (config.foxflake.gaming.hdr) { PROTON_ENABLE_HDR = 1; }
        // lib.optionalAttrs (config.foxflake.gaming.hdr) { PROTON_ENABLE_WAYLAND = 1; }
      ;
    };

    hardware = {
      steam-hardware.enable = mkDefault true;
      uinput.enable = mkDefault true;
    };

    programs = {
      gamemode.enable = mkDefault true;
      gamescope = {
        enable = mkOverride 999 true;
        package = mkDefault pkgs.gamescope;
        capSysNice = mkDefault true;
      };
    };

    services.udev.packages = with pkgs; [ game-devices-udev-rules ];

  };

}
