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
      package = pkgs.appimage-run.override { extraPkgs = pkgs: with pkgs; [ dotnet-runtime icu libnotify libxcrypt-legacy webkitgtk_4_1 ]; };
    };

    programs.nix-ld = {
      enable = mkDefault true;
      libraries = with pkgs; [ alsa-lib at-spi2-atk at-spi2-core atk brotli bzip2 cairo cups curlWithGnuTls dbus dbus-glib desktop-file-utils e2fsprogs elfutils expat ffmpeg flac fontconfig freeglut freetype fribidi fuse fuse3 gdk-pixbuf git glew glib gmp gobject-introspection gsettings-desktop-schemas gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-ugly gtk2 gtk3 gtk4 harfbuzz hpl icu json-glib libappindicator-gtk2 libappindicator-gtk3 libbsd libcaca libcanberra libcap libdbusmenu libdrm libelf libgbm libgpg-error libgcrypt libGL libGLU libice libidn2 libjpeg libogg libpciaccess libpng libpsl libpulseaudio librsvg libsamplerate libsm libthai libtheora libtiff libuuid libva libvdpau libvorbis libvpx libx11 libxcb libxcb-image libxcb-keysyms libxcb-render-util libxcb-wm libxcomposite libxcrypt libxcursor libxdamage libxext libxfixes libxft libxi libxinerama libxkbcommon libxml2 libxmu libxrandr libxrender libxscrnsaver libxshmfence libxt libxxf86vm mesa mesa.llvmPackages.llvm.lib mono nghttp2.lib nspr nss ocl-icd openssl p11-kit pango pkcs11helper pipewire pixman procps python3 rtmpdump rocmPackages.clr sane-backends SDL_image SDL_mixer SDL_ttf SDL2_image SDL2_mixer SDL2_ttf shared-mime-info skia speex stdenv.cc.cc sudo systemd tbb udev vulkan-loader vulkan-loader vulkan-tools wayland xz zlib zstd ];
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

    systemd.tmpfiles.rules = [
      "L /usr/bin/bash - - - - /run/current-system/sw/bin/bash"
      "L /usr/bin/env - - - - /run/current-system/sw/bin/env"
    ];

  };

}
