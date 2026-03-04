{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "podman" config.foxflake.system.applications) {

    virtualisation = {
      containers.enable = mkDefault true;
      podman = {
        enable = mkDefault true;
        dockerCompat = mkDefault (!(builtins.elem "distrobox" config.foxflake.system.applications || builtins.elem "docker" config.foxflake.system.applications || builtins.elem "winboat" config.foxflake.system.applications));
        defaultNetwork.settings.dns_enabled = mkDefault true;
      };
    };

  };

}
