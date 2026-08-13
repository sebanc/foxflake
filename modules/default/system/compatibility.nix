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
        appimageTools = prev.appimageTools // {
          appimage-exec = prev.writeShellApplication {
            name = "appimage-exec.sh";
            bashOptions = [ "errexit" "pipefail" ];
            runtimeInputs = with prev; [ binutils dwarfs gnutar pv squashfsTools ];
            text = builtins.replaceStrings
              [ ''unsquashfs -q -d "$out" -o "$offset" "$src"'' ]
              [ ''
                dwarfs="$(dd if="$src" bs=1 skip="$offset" count=6 2>/dev/null | tr -d "\0")"
                if [ "$dwarfs" == "DWARFS" ]; then
                  echo "Detected DwarFS payload, using dwarfsextract"
                  mkdir -p "$out"
                  dwarfsextract -i "$src" -O "$offset" -o "$out"
                else
                  echo "Using default unsquashfs format"
                  unsquashfs -q -d "$out" -o "$offset" "$src"
                fi
              '' ]
              (builtins.readFile "${prev.path}/pkgs/build-support/appimage/appimage-exec.sh");
          };
        };
      })
    ];

    programs.appimage = {
      enable = mkDefault true;
      binfmt = mkDefault true;
      package = mkDefault pkgs.appimage-run-foxflake;
    };

    programs.nix-ld = {
      enable = mkDefault true;
      libraries = with pkgs; [ alsa-lib alsa-plugins at-spi2-atk at-spi2-core atk brotli bzip2 cairo cups curlFull dbus dbus-glib desktop-file-utils dotnet-runtime dwarfs e2fsprogs elfutils expat ffmpeg file flac fontconfig freeglut freetype fribidi fuse fuse3 gdk-pixbuf git glew glib glib-networking gmp gnutls gobject-introspection graphene gsettings-desktop-schemas gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-bad gst_all_1.gst-plugins-ugly gtk2 gtk2.dev gtk3 gtk3.dev gtk4 gtk4.dev harfbuzz hpl icu jre json-glib libadwaita libappindicator-gtk2 libappindicator-gtk3 libayatana-appindicator libbsd libcaca libcanberra libcap libdbusmenu libdrm libelf libepoxy libgbm libgpg-error libgcrypt libGL libGLU libice libidn2 libjpeg libmanette libnotify libogg libpciaccess libpng libpsl libpulseaudio librsvg libsamplerate libsecret libsm libsoup_3 libthai libtheora libtiff libunwind libuuid libv4l libva libvdpau libvorbis libvpx libx11 libxcb libxcb-cursor libxcb-errors libxcb-image libxcb-keysyms libxcb-render-util libxcb-util libxcb-wm libxcomposite libxcrypt libxcrypt-legacy libxcursor libxdamage libxext libxfixes libxft libxi libxinerama libxkbcommon libxml2 libxmu libxrandr libxrender libxscrnsaver libxshmfence libxt libxtst libxxf86vm mesa mono nghttp2.lib nspr nss ocl-icd openssl p11-kit pango patchelf pcscliteWithPolkit pkcs11helper pipewire pixman procps rtmpdump rocmPackages.clr rocmPackages.hiprt sane-backends SDL_image SDL_mixer SDL_ttf SDL2_image SDL2_mixer SDL2_ttf shared-mime-info skia speex stdenv.cc.cc sudo systemd tbb udev vulkan-loader wayland webkitgtk_4_1 webkitgtk_6_0 xz zlib zstd ] ++ optionals (config.foxflake.graphics.compute.enable) (with pkgs; [ rocmPackages.hipblas rocmPackages.rocblas ]);
    };

    environment.systemPackages = with pkgs; [
      (pkgs.writeShellScriptBin "python" ''    
      if [ -d /usr/lib64 ]; then
        export LD_LIBRARY_PATH=/usr/lib64
        export GI_TYPELIB_PATH=/usr/lib64/girepository-1.0
      else
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
        export GI_TYPELIB_PATH=$NIX_LD_LIBRARY_PATH/girepository-1.0
      fi
      exec ${pkgs.python3.withPackages (module: [ module.pygobject3 module.pyqt6 ])}/bin/python "$@"
      '')
      (pkgs.writeShellScriptBin "python3" ''
      if [ -d /usr/lib64 ]; then
        export LD_LIBRARY_PATH=/usr/lib64
        export GI_TYPELIB_PATH=/usr/lib64/girepository-1.0
      else
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
        export GI_TYPELIB_PATH=$NIX_LD_LIBRARY_PATH/girepository-1.0
      fi
      exec ${pkgs.python3.withPackages (module: [ module.pygobject3 module.pyqt6 ])}/bin/python "$@"
      '')
    ];

  };

}
