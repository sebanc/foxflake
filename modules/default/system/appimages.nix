{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = {

    programs.appimage = {
      enable = mkDefault true;
      binfmt = mkDefault true;
    };

    programs.nix-ld = {
      enable = mkDefault true;
      libraries = with pkgs; [ alsa-lib atk brotli cairo cups curlWithGnuTls dbus dbus-glib elfutils expat ffmpeg fontconfig freetype fuse3 gdk-pixbuf git glew glib gobject-introspection gsettings-desktop-schemas gst_all_1.gstreamer gst_all_1.gst-plugins-ugly gst_all_1.gst-plugins-base gtk3 harfbuzz hpl icu json-glib libbsd libcap libdrm libelf libgbm libgcrypt libGL libGLU libidn2 libjpeg libogg libpng libpsl librsvg libtiff libuuid libva libvdpau libvorbis libvpx libxcrypt libxkbcommon mesa.llvmPackages.llvm.lib mono nghttp2.lib nspr nss ocl-icd pango pkcs11helper pipewire procps python3 rtmpdump rocmPackages.clr sane-backends SDL_image SDL_mixer SDL_ttf SDL2_image SDL2_mixer SDL2_ttf shared-mime-info skia sudo systemd udev vulkan-loader vulkan-tools wayland xorg.libICE xorg.libpciaccess xorg.libSM xorg.libX11 xorg.libxcb xorg.libXcomposite xorg.libXcursor xorg.libXdamage xorg.libXext xorg.libXfixes xorg.libXft xorg.libXi xorg.libXinerama xorg.libXmu xorg.libXrandr xorg.libXrender xorg.libXScrnSaver xorg.libxshmfence xorg.libXt xorg.libXxf86vm xorg.xcbutilimage xorg.xcbutilkeysyms xorg.xcbutilrenderutil xorg.xcbutilwm zstd ];
    };

    environment.systemPackages = [
      (pkgs.writeShellScriptBin "python" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${pkgs.python3}/bin/python "$@"
      '')
      (pkgs.writeShellScriptBin "python3" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${pkgs.python3}/bin/python "$@"
      '')
    ];

    environment.sessionVariables = {
      DOTNET_ROOT = "${pkgs.dotnet-runtime}/share/dotnet";
      LD_LIBRARY_PATH = [ "${pkgs.webkitgtk_4_1}/lib" "${pkgs.libnotify}/lib" ];
    };

  };

}
