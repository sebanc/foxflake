{ lib
, stdenv
, fetchurl
, librsvg
}:

let
  current_folder = ./.;
  icon = fetchurl {
    url = "file://${current_folder}/foxflake-default-icon.svg";
    sha256 = "1ea334c97c077c5ed112a15d1bafdbb61f96ba5fa32843f46b33171cc1b05172";
  };
in

stdenv.mkDerivation rec {
  pname = "foxflake-icons";
  version = "1.0.0";
  nativeBuildInputs = [
    librsvg
  ];

  postInstall = ''
    for i in 16 24 48 64 96 128 256 512; do
      mkdir -p $out/share/icons/hicolor/''${i}x''${i}/apps
      rsvg-convert ${icon} -w ''${i} -h ''${i} -f svg -o $out/share/icons/hicolor/''${i}x''${i}/apps/foxflake-default-icon.svg
    done
  '';
  dontUnpack = true;
  dontBuild = true;
}
