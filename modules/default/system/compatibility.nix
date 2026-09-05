{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.system.compatibility = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable FoxFlake appimages and scripts compatibility tweaks.";
    };
  };

  config = mkIf (config.foxflake.system.compatibility.enable) {

    nixpkgs.overlays = [
      (final: prev: {
        buildFHSEnv = args: prev.buildFHSEnv (
          args // {
            extraBuildCommands = (args.extraBuildCommands or "") + ''
              ln -sf libFLAC.so $out/usr/lib64/libFLAC.so.8
            '';
          }
        );
        appimage-run-foxflake = prev.runCommand "appimage-run-foxflake" {
          meta = (prev.appimage-run.meta or { }) // {
            mainProgram = "appimage-run";
          };
        } ''
          mkdir -p $out/bin
          cp "$(readlink -f ${prev.appimage-run.override { extraPkgs = pkgs: config.programs.nix-ld.libraries; }}/bin/appimage-run)" $out/bin/appimage-run
          chmod +w $out/bin/appimage-run
          substituteInPlace $out/bin/appimage-run \
            --replace-fail \
              'exec "''${cmd[@]}"' \
              'if [ ! -z "$APPIMAGE_USE_NIX_LD" ] && [ "$APPIMAGE_USE_NIX_LD" -eq 1 ]; then
                echo "APPIMAGE_USE_NIX_LD is set to 1, using Nix-ld instead of appimage-run FHSEnv"
                exec ${final.appimageTools.appimage-exec}/bin/appimage-exec.sh "$@"
              fi
              exec "''${cmd[@]}"'
          chmod +x $out/bin/appimage-run
        '';
        appimageTools = prev.appimageTools // {
          appimage-exec = prev.writeShellApplication {
            name = "appimage-exec.sh";
            bashOptions = [ "errexit" "pipefail" ];
            runtimeInputs = with final; [ binutils gnutar pv squashfsTools stable.dwarfs ];
            text = builtins.replaceStrings
              [ ''unsquashfs -q -d "$out" -o "$offset" "$src"'' ]
              [ ''
                dwarfs="$(dd if="$src" bs=1 skip="$offset" count=6 2>/dev/null | tr -d "\0")"
                if [ "$dwarfs" == "DWARFS" ]; then
                  echo "Detected DwarFS payload, using dwarfsextract"
                  mkdir -p "$out"
                  dwarfsextract -o "$out" -O "$offset" -i "$src"
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
      libraries = with pkgs; [ alsa-lib alsa-plugins at-spi2-atk at-spi2-core atk brotli bzip2 cairo cups curlFull dbus dbus-glib desktop-file-utils dotnet-runtime e2fsprogs elfutils expat ffmpeg file flac fontconfig freeglut freetype fribidi fuse fuse3 gdk-pixbuf git glew glib glib-networking gmp gnutls gobject-introspection graphene gsettings-desktop-schemas gst_all_1.gstreamer gst_all_1.gst-plugins-base gst_all_1.gst-plugins-bad gst_all_1.gst-plugins-ugly gtk2 gtk2.dev gtk3 gtk3.dev gtk4 gtk4.dev harfbuzz hpl icu jre json-glib libadwaita libappindicator-gtk3 libayatana-appindicator libbsd libcaca libcanberra libcap libdbusmenu libdrm libelf libepoxy libffi libgbm libgpg-error libgcrypt libGL libGLU libice libidn2 libjpeg libmanette libnotify libogg libpciaccess libpng libpsl libpulseaudio librsvg libsamplerate libsecret libsm libsoup_3 libthai libtheora libtiff libunwind libuuid libv4l libva libvdpau libvorbis libvpx libx11 libxcb libxcb-cursor libxcb-errors libxcb-image libxcb-keysyms libxcb-render-util libxcb-util libxcb-wm libxcomposite libxcrypt libxcrypt-legacy libxcursor libxdamage libxext libxfixes libxft libxi libxinerama libxkbcommon libxml2 libxmu libxrandr libxrender libxscrnsaver libxshmfence libxt libxtst libxxf86vm libyaml mesa mono nghttp2.lib nspr nss ocl-icd openssl p11-kit pango patchelf pcscliteWithPolkit pkcs11helper pipewire pixman procps rtmpdump rocmPackages.clr rocmPackages.hiprt sane-backends SDL_image SDL_mixer SDL_ttf SDL2_image SDL2_mixer SDL2_ttf shared-mime-info skia speex sqlite stdenv.cc.cc sudo systemd tbb udev vulkan-loader wayland webkitgtk_4_1 webkitgtk_6_0 xz zlib zstd ]
        ++ optionals (config.foxflake.graphics.compute) (with pkgs; [ rocmPackages.hipblas rocmPackages.rocblas ])
        ++ optionals (config.foxflake.nvidia.enable) (with pkgs; [ config.hardware.nvidia.package ])
        ++ optionals (config.foxflake.nvidia.enable && config.foxflake.graphics.compute) (with pkgs; [ cudaPackages.cudnn cudaPackages.libcublas cudaPackages.libcusolver cudaPackages.libcusparse ]);
    };

    environment = {
      systemPackages = with pkgs; [
        (pkgs.writeShellScriptBin "foxflake-run" ''
          # Enable the Nvidia GPU by default if detected
          if [ -e /dev/nvidia0 ] && [ -f /run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json ] && [ ! "$FOXFLAKE_DISABLE_NVIDIA_FIX" == "1" ]; then
            echo "foxflake-run: NVIDIA GPU detected, giving it priority. This behavior can be reverted by setting FOXFLAKE_DISABLE_NVIDIA_FIX=1."
            export VK_DRIVER_FILES=/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.json
            export __GLX_VENDOR_LIBRARY_NAME=nvidia
          fi

          # Add custom environment variables when launching standalone binaries to improve Nix-ld support
          bin="$1"; shift || true
          interp="$(${pkgs.patchelf}/bin/patchelf --print-interpreter "$bin" 2>/dev/null || true)"
          if [ ! -z "$interp" ] && ! grep -q '/nix/store' "$interp"; then
            export XLOCALEDIR="${pkgs.libx11}/share/X11/locale"
            export XKB_CONFIG_ROOT="${pkgs.xkeyboard_config}/etc/X11/xkb"
          fi

          exec "$bin" "$@"
        '')
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

  };

}
