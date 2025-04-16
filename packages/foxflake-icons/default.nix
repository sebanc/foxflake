{ lib
, stdenv
, fetchurl
, librsvg
}:

let
  current_folder = ./.;
  icon = fetchurl {
    url = "file://${current_folder}/foxflake-default-icon.svg";
    sha256 = "fd6753b4ff5e8de04bfd4972347fa8a6d649f641450f32b34e53b3adce9dbbbf";
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
