{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "librewolf" config.foxflake.system.applications) {

    environment.systemPackages = [ 
      (pkgs.stable.librewolf.overrideAttrs (oldAttrs: {
        makeWrapperArgs = (oldAttrs.makeWrapperArgs or []) ++ [
          "--suffix" "XDG_DATA_DIRS" ":"
          "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
        ];
      }))
    ];

  };

}
