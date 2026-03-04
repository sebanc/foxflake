{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      foxflake-update = self.stdenv.mkDerivation rec {
        name = "foxflake-update";
        buildCommand = let
          script = self.writeShellApplication {
            name = name;
            bashOptions = [ "errexit" "pipefail" ];
            excludeShellChecks = [ "SC2028" ];
            text = ''
set -e

if [ "$(${self.coreutils}/bin/id -u)" -ne 0 ]; then
	exec /run/wrappers/bin/sudo "$0"
fi

${self.nix}/bin/nix flake update --flake /etc/nixos
${self.nixos-rebuild}/bin/nixos-rebuild boot --flake /etc/nixos#foxflake --show-trace
            '';
          };
        in ''
mkdir -p $out/bin
cp ${script}/bin/${name} $out/bin
        '';
        dontBuild = true;
      };
    })
  ];
}
