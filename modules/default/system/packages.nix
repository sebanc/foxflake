{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.system = {
    bundles = mkOption {
      description = "bundles selection";
      type = with types; listOf str;
      default = [ "standard" ];
    };
    packages = mkOption {
      type = with types; listOf package;
      default = with pkgs; [ ];
      example = literalExpression "with pkgs; [ firefox ]";
      description = ''
        The set of packages that should be made available to all users.
      '';
    };
    flatpaks = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = literalExpression "[ { appId = \"org.mozilla.firefox\"; origin = \"flathub\"; } ]";
      description = ''
        The set of packages that should be installed as flatpak.
      '';
    };
    waydroid = mkOption {
      type = with types; bool;
      default = false;
      description = ''
        The Waydroid application that allows you to use Android apps on your computer.
      '';
    };
  };

  config = {

    environment.systemPackages = config.foxflake.system.packages ++ with pkgs; [ bzip2 dmidecode efibootmgr p7zip ];

    programs.appimage = {
      enable = mkDefault true;
      binfmt = mkDefault true;
    };

    programs.nix-ld = {
      enable = mkDefault true;
      libraries = with pkgs; [ alsa-lib atk brotli cairo cups curlWithGnuTls dbus dbus-glib elfutils expat ffmpeg fontconfig freetype fuse3 gdk-pixbuf glew glib gobject-introspection gsettings-desktop-schemas gst_all_1.gstreamer gst_all_1.gst-plugins-ugly gst_all_1.gst-plugins-base gtk3 harfbuzz hpl icu json-glib libbsd libcap libdrm libelf libgbm libgcrypt libGL libGLU libidn2 libjpeg libogg libpng libpsl librsvg libtiff libuuid libva libvdpau libvorbis libvpx libxcrypt libxkbcommon mesa.llvmPackages.llvm.lib mono nghttp2.lib nspr nss ocl-icd pango pkcs11helper pipewire procps rtmpdump rocmPackages.clr sane-backends SDL_image SDL_mixer SDL_ttf SDL2_image SDL2_mixer SDL2_ttf shared-mime-info skia sudo systemd udev vulkan-loader vulkan-tools wayland xorg.libICE xorg.libpciaccess xorg.libSM xorg.libX11 xorg.libxcb xorg.libXcomposite xorg.libXcursor xorg.libXdamage xorg.libXext xorg.libXfixes xorg.libXft xorg.libXi xorg.libXinerama xorg.libXmu xorg.libXrandr xorg.libXrender xorg.libXScrnSaver xorg.libxshmfence xorg.libXt xorg.libXxf86vm xorg.xcbutilimage xorg.xcbutilkeysyms xorg.xcbutilrenderutil xorg.xcbutilwm ];
    };

    services.flatpak = {
      enable = mkDefault true;
      remotes = mkDefault [
        {
          name = "flathub";
          location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
        {
          name = "flathub-beta";
          location = "https://dl.flathub.org/beta-repo/flathub-beta.flatpakrepo";
        }
      ];
      packages = mkDefault config.foxflake.system.flatpaks;
    };

  };

}
