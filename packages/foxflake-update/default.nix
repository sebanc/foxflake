{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      foxflake-update = prev.stdenv.mkDerivation rec {
        name = "foxflake-update";
        buildCommand = let script = prev.writeShellApplication {
          name = name;
          runtimeInputs = with final; [ nix nixos-rebuild ];
          bashOptions = [ "errexit" "pipefail" ];
          excludeShellChecks = [ "SC2028" ];
          text = ''
if [ "$(id -u)" -ne 0 ]; then
	exec /run/wrappers/bin/sudo "$0" "$@"
fi

nix flake update --flake /etc/nixos
nixos-rebuild boot --flake /etc/nixos#foxflake --show-trace "$@"
          '';
        };
        desktopEntry = prev.makeDesktopItem {
          name = name;
          desktopName = "FoxFlake Update";
          icon = "foxflake-grey-icon";
          exec = "/run/current-system/sw/bin/foxflake-update";
          terminal = true;
          categories = [ "System" ];
        };
        in ''
mkdir -p $out/bin
cp ${script}/bin/${name} $out/bin
mkdir -p $out/share/applications
cp ${desktopEntry}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
        '';
      };
    })
  ];
}
