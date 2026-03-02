{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "gaming-optimizations" config.foxflake.system.applications) {

    boot.kernel.sysctl = {
      "kernel.split_lock_mitigate" = mkOverride 999 0;
      "net.ipv4.tcp_slow_start_after_idle" = mkOverride 999 0;
      "net.ipv4.tcp_fastopen" = mkOverride 999 3;
      "vm.dirty_background_ratio" = mkOverride 999 5;
      "vm.dirty_expire_centisecs" = mkOverride 999 3000;
      "vm.dirty_ratio" = mkOverride 999 10;
      "vm.dirty_writeback_centisecs" = mkOverride 999 500;
      "vm.max_map_count" = mkOverride 999 2147483642;
    };
    services.scx = {
      enable = mkDefault true;
      scheduler = mkDefault "scx_lavd";
      extraArgs = mkDefault [ "--autopower" ];
    };

  };

}
