{ lib
, stdenv
, fetchurl
, librsvg
}:

let
  current_folder = ./.;
  icon = fetchurl {
    url = "file://${current_folder}/foxflake-default-icon.svg";
    sha256 = "92234df3be9edeaf0c1a6be5b544c67cc6be73f8d3e5911f6b58c8e3a60637d2";
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
