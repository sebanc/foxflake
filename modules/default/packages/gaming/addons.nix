{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "gaming" config.foxflake.system.applications || builtins.elem "faugus" config.foxflake.system.applications || builtins.elem "heroic" config.foxflake.system.applications || builtins.elem "lutris" config.foxflake.system.applications || builtins.elem "steam" config.foxflake.system.applications) {

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
