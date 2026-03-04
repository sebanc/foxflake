{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "gaming" config.foxflake.system.applications || builtins.elem "faugus" config.foxflake.system.applications || builtins.elem "goverlay" config.foxflake.system.applications || builtins.elem "heroic" config.foxflake.system.applications || builtins.elem "lutris" config.foxflake.system.applications || builtins.elem "mangojuice" config.foxflake.system.applications || builtins.elem "steam" config.foxflake.system.applications) {

    boot.kernel.sysctl = {
      "kernel.split_lock_mitigate" = mkOverride 999 0;
      "net.ipv4.tcp_slow_start_after_idle" = mkOverride 999 0;
      "net.ipv4.tcp_fastopen" = mkOverride 999 3;
      "vm.max_map_count" = mkOverride 999 2147483642;
      "vm.swappiness" = mkOverride 999 10;
    };
    environment.systemPackages = with pkgs; [
      gamescope
      joystickwake
      mangohud
      vkbasalt
    ];
    hardware.steam-hardware.enable = mkDefault true;
    programs.gamemode.enable = mkDefault true;

  };

}
