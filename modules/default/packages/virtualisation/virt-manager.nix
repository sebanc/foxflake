{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "virt-manager" config.foxflake.system.applications) {

    virtualisation.libvirtd = {
      enable = mkDefault true;
      package = mkDefault pkgs.stable.libvirt;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };
    programs.virt-manager = {
      enable = mkDefault true;
      package = mkDefault pkgs.stable.virt-manager;
    };
    networking.firewall.trustedInterfaces = [ "virbr0" ];

  };

}
