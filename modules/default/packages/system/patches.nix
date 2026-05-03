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
      openldap = inputs.nixpkgs-stable.legacyPackages.${prev.stdenv.hostPlatform.system}.openldap;
      xdg-desktop-portal = prev.xdg-desktop-portal.overrideAttrs (oldAttrs: { doCheck = false; });
    })];

  };

}
