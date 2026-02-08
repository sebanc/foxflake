{ lib, stdenv}:
let
  wallpapers = "foxflake-light-wallpaper foxflake-neon-wallpaper";
in
stdenv.mkDerivation {
  name = "foxflake-wallpapers";
  src = ./.;

  installPhase = ''
    for wallpaper in ${wallpapers}; do

      # GNOME CONFIGURATION
      mkdir -p $out/share/backgrounds/foxflake $out/share/gnome-background-properties
      cp ''${wallpaper}.png $out/share/backgrounds/foxflake/''${wallpaper}.png
      cat >$out/share/gnome-background-properties/''${wallpaper}.xml <<FOXFLAKE_GNOME_CONF
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE wallpapers SYSTEM "gnome-wp-list.dtd">
    <wallpapers>
      <wallpaper deleted="false">
        <name>''${wallpaper}</name>
        <filename>$out/share/backgrounds/foxflake/''${wallpaper}.png</filename>
        <options>zoom</options>
        <shade_type>solid</shade_type>
        <pcolor>#ffffff</pcolor>
        <scolor>#000000</scolor>
      </wallpaper>
    </wallpapers>
    FOXFLAKE_GNOME_CONF

      # PLASMA CONFIGURATION
      mkdir -p $out/share/wallpapers/''${wallpaper}/contents/images
      cp ''${wallpaper}.png $out/share/wallpapers/''${wallpaper}/contents/images/''${wallpaper}.png
      cat >$out/share/wallpapers/''${wallpaper}/metadata.desktop <<FOXFLAKE_PLASMA_CONF
    [Desktop Entry]
    Name=''${wallpaper}
    X-KDE-PluginInfo-Name=''${wallpaper}
    FOXFLAKE_PLASMA_CONF

    done
  '';
}
