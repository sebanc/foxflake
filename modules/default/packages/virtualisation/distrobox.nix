{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "distrobox" config.foxflake.system.applications) {

    virtualisation = {
      containers.enable = mkDefault true;
      podman = {
        enable = mkDefault true;
        defaultNetwork.settings.dns_enabled = mkDefault true;
      };
      docker.enable = mkDefault true;
    };
    environment.systemPackages = with pkgs; [ distrobox ];

  };

}
