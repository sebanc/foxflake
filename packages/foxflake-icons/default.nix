{ lib
, stdenv
, fetchurl
, librsvg
}:

let
  current_folder = ./.;
  icon_light = fetchurl {
    url = "file://${current_folder}/foxflake-icon-light.svg";
    sha256 = "064e105f73b195982671920b0866f4ef1e3a73fdf02b152eb69625c4098f184c";
  };
  icon_dark = fetchurl {
    url = "file://${current_folder}/foxflake-icon-dark.svg";
    sha256 = "8443519eb29fe90ba4d42ea0e8b30d800b2842e0668949a48fe2cd0f3372c317";
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
