{ pkgs, ... }:

let
  icons = "foxflake-black-icon foxflake-blue-icon foxflake-green-icon foxflake-grey-icon foxflake-red-icon";
in
{
  nixpkgs.overlays = [
    (final: prev: {
      foxflake-icons = prev.stdenv.mkDerivation {
        name = "foxflake-icons";
        src = ./.;
        nativeBuildInputs = with final; [
          librsvg
        ];
        installPhase = ''
for icon in ${icons}; do
  for size in 16 24 48 64 96 128 256 512; do
    mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
    ${final.librsvg}/bin/rsvg-convert ''${icon}.svg -w ''${size} -h ''${size} -f svg -o $out/share/icons/hicolor/''${size}x''${size}/apps/''${icon}.svg
  done
done
        '';
      };
    })
  ];
}
