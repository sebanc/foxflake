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
      openldap = prev.openldap.overrideAttrs (oldAttrs: { doCheck = false; });
      xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (oldAttrs: { doCheck = false; });
    })];

  };

}
