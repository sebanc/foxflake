{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

let
  LinuxloopsLauncher = pkgs.writeShellApplication {
    name = "linuxloops-launcher";
    runtimeInputs = with pkgs; [ curl gnupg1 (pkgs.python3.withPackages (module: [ module.pygobject3 ])) xz zenity ];
    bashOptions = [ ];
    text = ''
      export GI_TYPELIB_PATH="${lib.makeSearchPath "lib/girepository-1.0" (with pkgs; [ at-spi2-atk at-spi2-core atk cairo gdk-pixbuf glib gobject-introspection gtk3 harfbuzz libsoup_3 pango.out webkitgtk_4_1 ])}"
      export GIO_MODULE_DIR=${pkgs.glib-networking}/lib/gio/modules
      export XDG_DATA_DIRS="${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}:${pkgs.adwaita-icon-theme}/share:${pkgs.hicolor-icon-theme}/share"
      rm -rf /var/lib/linuxloops
      mkdir -p /var/lib/linuxloops
      curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/sebanc/linuxloops/raw/refs/heads/main/linuxloops -o /var/lib/linuxloops/linuxloops || zenity --height=480 --width=640 --title="LinuxLoops launcher" --error --text="Please make sure you have internet connectivity before running this program.\n" 2>/dev/null
      chmod 0755 "/var/lib/linuxloops/linuxloops"
      /var/lib/linuxloops/linuxloops "$@"
      rm -rf /var/lib/linuxloops
      exit 0
    '';
  };
in
{
  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "linuxloops" config.foxflake.system.applications) {

    nixpkgs.overlays = [
      (final: prev: {
        foxflake-linuxloops-integration = prev.stdenv.mkDerivation rec {
          name = "foxflake-linuxloops-integration";
          buildCommand = let
            script = prev.writeShellApplication {
              name = name;
              runtimeInputs = with final; [ zenity ];
              bashOptions = [ "errexit" "pipefail" ];
              text = ''
                sudo -n ${LinuxloopsLauncher}/bin/linuxloops-launcher "$@" || zenity --height=200 --width=640 --title="LinuxLoops launcher" --error --text="Linuxloops is only available to admin users (wheel group).\n" 2>/dev/null
              '';
            };
            desktopEntry = prev.makeDesktopItem {
              name = name;
              desktopName = "Linuxloops";
              icon = "foxflake-grey-icon";
              exec = "linuxloops";
              startupWMClass = "Linuxloops";
              terminal = true;
              categories = [ "System" ];
            };
          in ''
            mkdir -p $out/bin
            cp ${script}/bin/${name} $out/bin/linuxloops
            mkdir -p $out/share/applications
            cp ${desktopEntry}/share/applications/${name}.desktop $out/share/applications/linuxloops.desktop
          '';
        };
      })
    ];

    environment.systemPackages = with pkgs; [ foxflake-linuxloops-integration ];

    security.sudo.extraRules = [{
      groups = [ "wheel" ];
      commands = [{
        command = "${LinuxloopsLauncher}/bin/linuxloops-launcher";
        options = [ "NOPASSWD" ];
      }];
    }];

  };
}
