{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = {

    nixpkgs.overlays = [
      (final: prev: {
        appimage-run-foxflake = (prev.appimage-run.override {
          extraPkgs = pkgs: config.programs.nix-ld.libraries; 
        });
      })
    ];

    programs.appimage = {
      enable = mkDefault true;
      binfmt = mkDefault true;
      package = mkDefault pkgs.appimage-run-foxflake;
    };

    programs.nix-ld = {
      enable = mkDefault true;
      libraries = with pkgs; [ alsa-lib at-spi2-atk at-spi2-core atk brotli bzip2 cairo cups curlFull dbus dbus-glib desktop-file-utils dotnet-runtime e2fsprogs elfutils expat ffmpeg flac fontconfig freeglut freetype fribidi fuse fuse3 gdk-pixbuf git glew glib glib-networking gmp gnutls gobject-introspection gsettings-desktop-schemas gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-bad gst_all_1.gst-plugins-ugly gtk2 gtk3 gtk4 harfbuzz hpl icu json-glib libappindicator-gtk2 libappindicator-gtk3 libbsd libcaca libcanberra libcap libdbusmenu libdrm libelf libepoxy libgbm libgpg-error libgcrypt libGL libGLU libice libidn2 libjpeg libnotify libogg libpciaccess libpng libpsl libpulseaudio librsvg libsamplerate libsm libsoup_3 libthai libtheora libtiff libunwind libuuid libv4l libva libvdpau libvorbis libvpx libx11 libxcb libxcb-cursor libxcb-errors libxcb-image libxcb-keysyms libxcb-render-util libxcb-util libxcb-wm libxcomposite libxcrypt libxcrypt-legacy libxcursor libxdamage libxext libxfixes libxft libxi libxinerama libxkbcommon libxml2 libxmu libxrandr libxrender libxscrnsaver libxshmfence libxt libxtst libxxf86vm mesa mesa.llvmPackages.llvm.lib mono nghttp2.lib nspr nss ocl-icd openssl p11-kit pango pcscliteWithPolkit pkcs11helper pipewire pixman procps rtmpdump rocmPackages.clr sane-backends SDL_image SDL_mixer SDL_ttf SDL2_image SDL2_mixer SDL2_ttf shared-mime-info skia speex stdenv.cc.cc sudo systemd tbb udev vulkan-loader vulkan-tools wayland webkitgtk_4_1 xz zlib zstd ];
    };

    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "python" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${pkgs.python3.withPackages (module: [ module.pyqt6 ])}/bin/python "$@"
      '')
      (pkgs.writeShellScriptBin "python3" ''
      export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
      exec ${pkgs.python3.withPackages (module: [ module.pyqt6 ])}/bin/python "$@"
      '')
    ];

    systemd.tmpfiles.rules = [
      "d /usr/bin 0755 root root -"
    ];

  };

}
