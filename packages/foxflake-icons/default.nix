{ lib
, stdenv
, fetchurl
, librsvg
}:

let
  current_folder = ./.;
  icon_light = fetchurl {
    url = "file://${current_folder}/../../assets/icons/foxflake-icon-light.svg";
    sha256 = "1ea334c97c077c5ed112a15d1bafdbb61f96ba5fa32843f46b33171cc1b05172";
  };
  icon_dark = fetchurl {
    url = "file://${current_folder}/../../assets/icons/foxflake-icon-dark.svg";
    sha256 = "064e105f73b195982671920b0866f4ef1e3a73fdf02b152eb69625c4098f184c";
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
      rsvg-convert ${icon_light} -w ''${i} -h ''${i} -f svg -o $out/share/icons/hicolor/''${i}x''${i}/apps/foxflake-icon-light.svg
      rsvg-convert ${icon_dark} -w ''${i} -h ''${i} -f svg -o $out/share/icons/hicolor/''${i}x''${i}/apps/foxflake-icon-dark.svg
    done
  '';
  dontUnpack = true;
  dontBuild = true;
}
