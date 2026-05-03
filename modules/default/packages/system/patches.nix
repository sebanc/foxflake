{
  inputs,
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = {

    nixpkgs.overlays = [(final: prev: {
      gnupg = prev.gnupg.overrideAttrs (oldAttrs: { doCheck = false; });
      openldap = prev.openldap.overrideAttrs (oldAttrs: { doCheck = false; });
      xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (oldAttrs: { doCheck = false; });
    })];

  };

}
