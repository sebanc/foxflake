{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  imports = [
    ../../../packages/steamos-helpers
  ];

  options.foxflake.environment.steam = {
    display = mkOption {
      description = "The main display to use for the Steam session such as DP-1, eDP-1 or HDMI-A-1 ....";
      type = with types; str;
      default = "";
      example = "DP-1";
    };
    primarySession = mkOption {
      description = "Default environment if autologin is enabled.";
      type = with types; enum [ "plasma" "steam" ];
      default = "steam";
    };
    resolution = mkOption {
      description = "The main display resolution to use for the Steam session in the format <width>x<height>x<refresh rate>.";
      type = with types; str;
      default = "";
      example = "1920x1080x60";
    };
  };

  config = mkIf (config.foxflake.environment.enable && (config.foxflake.environment.type == "steam" || config.foxflake.environment.type == "steamdeck")) {

    environment = {
      systemPackages = with pkgs; [
        plymouth
        steamos-helpers
        xvfb-run
      ];
      variables = { }
        // lib.optionalAttrs (config.foxflake.environment.steam.display != "") { GAMESCOPE_SESSION_DISPLAY = "${config.foxflake.environment.steam.display}"; }
        // lib.optionalAttrs (config.foxflake.environment.steam.resolution != "") { GAMESCOPE_SESSION_RESOLUTION = "${config.foxflake.environment.steam.resolution}"; }
        // lib.optionalAttrs (config.foxflake.gaming.hdr) { GAMESCOPE_SESSION_HDR = 1; }
        // lib.optionalAttrs (config.foxflake.gaming.hdr) { STEAM_GAMESCOPE_HDR_SUPPORTED = 1; }
      ;
    };

    programs = {
      gamescope = {
        package = mkOverride 999 ((pkgs.stable.gamescope.override { enableWsi = true; }).overrideAttrs (old: {
          patches = (old.patches or []) ++ [ (pkgs.writeText "foxflake-specific.patch" ''
            diff -ruN -U 5 a/src/Backends/DRMBackend.cpp b/src/Backends/DRMBackend.cpp
            --- a/src/Backends/DRMBackend.cpp	2026-07-11 20:08:34.478614512 +0200
            +++ b/src/Backends/DRMBackend.cpp	2026-07-11 20:02:43.769657246 +0200
            @@ -67,12 +67,12 @@
             gamescope::ConVar<bool> cv_drm_debug_disable_output_tf( "drm_debug_disable_output_tf", false, "Force default (identity) output TF, affects other logic. Not a property directly." );
             gamescope::ConVar<bool> cv_drm_debug_disable_blend_tf( "drm_debug_disable_blend_tf", false, "Blending chicken bit. (Forces BLEND_TF to DEFAULT, does not affect other logic)" );
             gamescope::ConVar<bool> cv_drm_debug_disable_ctm( "drm_debug_disable_ctm", false, "CTM chicken bit. (Forces CTM off, does not affect other logic)" );
             gamescope::ConVar<bool> cv_drm_debug_disable_color_encoding( "drm_debug_disable_color_encoding", false, "YUV Color Encoding chicken bit. (Forces COLOR_ENCODING to DEFAULT, does not affect other logic)" );
             gamescope::ConVar<bool> cv_drm_debug_disable_color_range( "drm_debug_disable_color_range", false, "YUV Color Range chicken bit. (Forces COLOR_RANGE to DEFAULT, does not affect other logic)" );
            -gamescope::ConVar<bool> cv_drm_debug_disable_explicit_sync( "drm_debug_disable_explicit_sync", false, "Force disable explicit sync on the DRM backend." );
            -gamescope::ConVar<bool> cv_drm_debug_disable_in_fence_fd( "drm_debug_disable_in_fence_fd", false, "Force disable IN_FENCE_FD being set to avoid over-synchronization on the DRM backend." );
            +gamescope::ConVar<bool> cv_drm_debug_disable_explicit_sync( "drm_debug_disable_explicit_sync", true, "Force disable explicit sync on the DRM backend." );
            +gamescope::ConVar<bool> cv_drm_debug_disable_in_fence_fd( "drm_debug_disable_in_fence_fd", true, "Force disable IN_FENCE_FD being set to avoid over-synchronization on the DRM backend." );
             
             gamescope::ConVar<bool> cv_drm_allow_dynamic_modes_for_external_display( "drm_allow_dynamic_modes_for_external_display", false, "Allow dynamic mode/refresh rate switching for external displays." );
             
             int HackyDRMPresent( const FrameInfo_t *pFrameInfo, bool bAsync );
             
            diff -ruN -U 5 a/src/steamcompmgr.cpp b/src/steamcompmgr.cpp
            --- a/src/steamcompmgr.cpp	2026-07-11 20:08:34.484208906 +0200
            +++ b/src/steamcompmgr.cpp	2026-07-15 07:38:52.170317808 +0200
            @@ -3475,10 +3475,22 @@
             						localGameFocused = true;
             						goto found;
             					}
             				}
             			}
            +			else
            +			{
            +				for ( steamcompmgr_win_t *focusable_window : vecPossibleFocusWindows )
            +				{
            +					if ( focusable_window->isSteamLegacyBigPicture )
            +					{
            +						focus = focusable_window;
            +						localGameFocused = true;
            +						goto found;
            +					}
            +				}
            +			}
             
             			for ( auto focusable_appid : ctxFocusControlAppIDs )
             			{
             				for ( steamcompmgr_win_t *focusable_window : vecPossibleFocusWindows )
             				{
          '')];
        }));
      };
      steam = {
        extraPackages = with pkgs; [
          steamos-helpers
          (pkgs.runCommandLocal "breeze-cursor-default-theme" { } ''
            mkdir -p $out/share/icons
            ln -s ${pkgs.kdePackages.breeze}/share/icons/breeze_cursors $out/share/icons/default
          '')
        ];
        package = mkOverride 999 (pkgs.stable.steam.override {
          extraBwrapArgs = [
            "--bind" "/tmp" "/tmp"
            "--tmpfs" "/tmp/.X11-unix"
          ];
          extraProfile = ''
            RESOLV_CONF="${pkgs.writeText "steam-resolv.conf" ''
              nameserver 9.9.9.9
              nameserver 4.4.4.4
              nameserver 8.8.8.8
            ''}"
            cp -f "$RESOLV_CONF" /etc/resolv.conf || echo "warning: failed to override resolv.conf" >&2
          '';
          steam-unwrapped = pkgs.stable.steam-unwrapped.overrideAttrs (old: {
            postInstall = (old.postInstall or "") + ''
              cp ${pkgs.fetchurl {
                url = "https://steamdeck-packages.steamos.cloud/misc/steam-snapshots/steam_jupiter_stable_bootstrapped_20251031.0.tar.xz";
                hash = "sha256-A6Y7+eUV4Rwwrv8u0DilxeDBvTFHMBqzL33P+YwhCTs=";
              }} $out/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
              if [ "${config.foxflake.environment.type}" == "steamdeck" ]; then
                sed -i 's@Exec=steam@Exec=steam -steamos3 -steamdeck@g' $out/share/applications/steam.desktop
              elif [ "${config.foxflake.environment.type}" == "steam" ]; then
                sed -i 's@Exec=steam@Exec=steam -steamos3@g' $out/share/applications/steam.desktop
              fi
            '';
          });
        });
      };
    };

    security = {
      sudo = {
        extraRules = [
          {
            groups = [ "users" ];
            commands = [
              {
                command = "/run/current-system/sw/bin/plymouth";
                options = [ "NOPASSWD" ];
              }
            ];
          }
          {
            groups = [ "users" ];
            commands = [
              {
                command = "/run/current-system/sw/bin/plymouthd";
                options = [ "NOPASSWD" ];
              }
            ];
          }
        ];
      };
    };

    services = {
      displayManager = {
        defaultSession = mkOverride 999 "${config.foxflake.environment.steam.primarySession}";
        sddm.autoLogin.relogin = if config.foxflake.environment.autologin then mkDefault true else mkDefault false;
        sessionPackages = with pkgs; [ steamos-helpers ];
      };
      inputplumber.enable = mkDefault true;
    };

    systemd = {
      coredump.enable = mkDefault false;
      services."jupiter-biosupdate" = {
        description = "Fake Jupiter BIOS update service";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.coreutils}/bin/true";
        };
        restartIfChanged = false;
      };
      services."jupiter-controller-update" = {
        description = "Fake Jupiter controller update service";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.coreutils}/bin/true";
        };
        restartIfChanged = false;
      };
      services."jupiter-fan-control" = {
        description = "Fake Jupiter fan control service";
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.coreutils}/bin/true";
        };
        restartIfChanged = false;
      };
      user.services = {
        "steamos-session-default" = {
          description = "Restore SteamOS as default session";
          before = [ "plasma-plasmashell.service" ];
          wantedBy = [ "plasma-core.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.writeShellScriptBin "steamos-session-default" ''
              #!${pkgs.bash}

              if [ ! -d ''${HOME}/.local/share/Steam ]; then
                mkdir -p ''${HOME}/.local/share/Steam
                echo "BootStrapperInhibitAll=enable" > ''${HOME}/.local/share/Steam/steam.cfg
              elif [ -f ''${HOME}/.local/share/Steam/steam.cfg ] && [ -f ''${HOME}/.local/share/Steam/config/loginusers.vdf ]; then
                grep -q "BootStrapperInhibitAll" ''${HOME}/.local/share/Steam/steam.cfg && sed -i '/BootStrapperInhibitAll/d' ''${HOME}/.local/share/Steam/steam.cfg
              fi

              echo -e '[Autologin]\nSession=steam' > /tmp/zz-steamos.conf
            ''}/bin/steamos-session-default";
          };
          restartIfChanged = false;
        };
        "cleanup-session" = {
          description = "Force kill Kwin to avoid drm conflicts";
          wantedBy = [ "graphical-session.target" ];
          partOf = [ "graphical-session.target" ];
          serviceConfig = {
            Type = "oneshot";
            RemainAfterExit = true;
            ExecStop = "${pkgs.writeShellScriptBin "cleanup-session" ''
              #!${pkgs.bash}

              ${pkgs.procps}/bin/pkill -KILL kwin
            ''}/bin/cleanup-session";
            TimeoutStopSec = "5s";
          };
          restartIfChanged = false;
        };
      };
      tmpfiles.rules = [
        "L+ /etc/sddm.conf.d/zz-steamos.conf - - - - /tmp/zz-steamos.conf"
      ];
    };

  };

}
