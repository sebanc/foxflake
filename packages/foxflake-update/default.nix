{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      foxflake-update = prev.stdenv.mkDerivation rec {
        name = "foxflake-update";
        buildCommand = let script = prev.writeShellApplication {
          name = name;
          bashOptions = [ "errexit" "pipefail" ];
          excludeShellChecks = [ "SC2028" ];
          text = ''
set -e

if [ "$(${final.coreutils}/bin/id -u)" -ne 0 ]; then
	exec /run/wrappers/bin/sudo "$0"
fi

${final.nix}/bin/nix flake update --flake /etc/nixos
${final.nixos-rebuild}/bin/nixos-rebuild boot --flake /etc/nixos#foxflake --show-trace
          '';
        };
        desktopEntry = prev.makeDesktopItem {
          name = name;
          desktopName = "FoxFlake Update";
          icon = "foxflake-red-icon";
          exec = "/run/current-system/sw/bin/foxflake-update";
          terminal = true;
          extraConfig = {
            NoDisplay = "true";
          };
        };
        in ''
mkdir -p $out/bin
cp ${script}/bin/${name} $out/bin
mkdir -p $out/share/applications
cp ${desktopEntry}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
        '';
        dontBuild = true;
      };
    })
  ];
}
