{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  imports = [ ../../../packages/steamos-helpers ];

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
    upscaleFrom = mkOption {
      description = "The resolution to upscale from in the format <width>x<height>.";
      type = with types; str;
      default = "";
      example = "1280x720";
    };
  };

  config = mkIf (config.foxflake.environment.enable && (config.foxflake.environment.type == "steam" || config.foxflake.environment.type == "steamdeck")) {

    environment = {
      systemPackages = with pkgs; [
        steamos-helpers
        xvfb-run
      ];
      variables = { }
        // lib.optionalAttrs (config.foxflake.environment.steam.display != "") { GAMESCOPE_SESSION_DISPLAY = "${config.foxflake.environment.steam.display}"; }
        // lib.optionalAttrs (config.foxflake.environment.steam.resolution != "") { GAMESCOPE_SESSION_RESOLUTION = "${config.foxflake.environment.steam.resolution}"; }
        // lib.optionalAttrs (config.foxflake.environment.steam.upscaleFrom != "") { GAMESCOPE_SESSION_UPSCALE = "${config.foxflake.environment.steam.upscaleFrom}"; }
        // lib.optionalAttrs (config.foxflake.gaming.hdr) { GAMESCOPE_SESSION_HDR = 1; }
        // lib.optionalAttrs (config.foxflake.gaming.hdr) { STEAM_GAMESCOPE_HDR_SUPPORTED = 1; }
      ;
    };

    programs.steam = {
      extraPackages = with pkgs; [
        steamos-helpers
        (pkgs.runCommandLocal "breeze-cursor-default-theme" { } ''
          mkdir -p $out/share/icons
          ln -s ${pkgs.kdePackages.breeze}/share/icons/breeze_cursors $out/share/icons/default
        '')
      ];
    };

    nixpkgs.config.packageOverrides = pkgs: {
      steam = pkgs.steam.override {
        extraBwrapArgs = [ "--bind /tmp /tmp" ];
        buildFHSEnv = args: (pkgs.buildFHSEnv.override {
          bubblewrap = "${config.security.wrapperDir}/..";
        }) args;
      };
      steam-unwrapped = pkgs.steam-unwrapped.overrideAttrs (old: {
        postInstall = (old.postInstall or "") + ''
          cp ${pkgs.fetchurl {
            url = "https://steamdeck-packages.steamos.cloud/misc/steam-snapshots/steam_jupiter_stable_bootstrapped_20251031.0.tar.xz";
            hash = "sha256-A6Y7+eUV4Rwwrv8u0DilxeDBvTFHMBqzL33P+YwhCTs=";
          }} $out/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
        '';
      } // (lib.optionalAttrs (config.foxflake.environment.type == "steamdeck") {
        postInstall = (old.postInstall or "") + ''
          cp ${pkgs.fetchurl {
            url = "https://steamdeck-packages.steamos.cloud/misc/steam-snapshots/steam_jupiter_stable_bootstrapped_20251031.0.tar.xz";
            hash = "sha256-A6Y7+eUV4Rwwrv8u0DilxeDBvTFHMBqzL33P+YwhCTs=";
          }} $out/lib/steam/bootstraplinux_ubuntu12_32.tar.xz
          sed -i 's@Exec=steam@Exec=steam -steamdeck@g' $out/share/applications/steam.desktop
        '';
      }));
      gamescope = pkgs.gamescope.overrideAttrs(old: rec {
        version = "3.16.23";
        src = pkgs.fetchFromGitHub {
          owner = "ValveSoftware";
          repo = "gamescope";
          rev = version;
          fetchSubmodules = true;
          hash = "sha256-q9AZTe6fBgJBt5/c3x8PVrnDF+MtRmQ1OWZq9ZsSe/M=";
        };
        patches = (old.patches or []) ++ [
          (pkgs.writeText "steam-bootstrap-fix.patch" ''
            --- a/src/steamcompmgr.cpp      2026-04-12 11:04:10.709969160 +0200
            +++ b/src/steamcompmgr.cpp      2026-04-12 20:20:53.296661240 +0200
            @@ -3490,6 +3490,16 @@
             					}
             				}
             			}
            +
            +			for ( steamcompmgr_win_t *focusable_window : vecPossibleFocusWindows )
            +			{
            +				if ( window_is_steam( focusable_window ) )
            +				{
            +					focus = focusable_window;
            +					localGameFocused = true;
            +					goto found;
            +				}
            +			}
             		}
             		else
             		{
            --- a/src/Backends/DRMBackend.cpp     2026-04-12 11:04:10.705969190 +0200
            +++ b/src/Backends/DRMBackend.cpp     2026-04-19 12:58:09.312287112 +0200
            @@ -69,8 +69,8 @@
             gamescope::ConVar<bool> cv_drm_debug_disable_ctm( "drm_debug_disable_ctm", false, "CTM chicken bit. (Forces CTM off, does not affect other logic)" );
             gamescope::ConVar<bool> cv_drm_debug_disable_color_encoding( "drm_debug_disable_color_encoding", false, "YUV Color Encoding chicken bit. (Forces COLOR_ENCODING to DEFAULT, does not affect other logic)" );
             gamescope::ConVar<bool> cv_drm_debug_disable_color_range( "drm_debug_disable_color_range", false, "YUV Color Range chicken bit. (Forces COLOR_RANGE to DEFAULT, does not affect other logic)" );
            -gamescope::ConVar<bool> cv_drm_debug_disable_explicit_sync( "drm_debug_disable_explicit_sync", false, "Force disable explicit sync on the DRM backend." );
            -gamescope::ConVar<bool> cv_drm_debug_disable_in_fence_fd( "drm_debug_disable_in_fence_fd", false, "Force disable IN_FENCE_FD being set to avoid over-synchronization on the DRM backend." );
            +gamescope::ConVar<bool> cv_drm_debug_disable_explicit_sync( "drm_debug_disable_explicit_sync", true, "Force disable explicit sync on the DRM backend." );
            +gamescope::ConVar<bool> cv_drm_debug_disable_in_fence_fd( "drm_debug_disable_in_fence_fd", true, "Force disable IN_FENCE_FD being set to avoid over-synchronization on the DRM backend." );
             
             gamescope::ConVar<bool> cv_drm_allow_dynamic_modes_for_external_display( "drm_allow_dynamic_modes_for_external_display", false, "Allow dynamic mode/refresh rate switching for external displays." );
             
          '')
        ];
      });
    };

    security = {
      wrappers = {
        bwrap = {
          owner = mkDefault "root";
          group = mkDefault "root";
          source = mkDefault "${pkgs.bubblewrap}/bin/bwrap";
          setuid = mkDefault true;
        };
      };
    };

    services = {
      displayManager = {
        defaultSession = mkOverride 999 "${config.foxflake.environment.steam.primarySession}";
        sddm.autoLogin.relogin = if config.foxflake.environment.autologin then mkDefault true else mkDefault false;
        sessionPackages = with pkgs; [ steamos-helpers ];
      };
      inputplumber.enable = mkDefault true;
      powerstation.enable = mkDefault true;
    };

    systemd = {
      coredump.enable = mkDefault false;
      user.services = {
        "steamos-session-default" = {
          description = "Restore SteamOS as default session";
          before = [ "plasma-plasmashell.service" ];
          wantedBy = [ "plasma-core.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.writeShellScriptBin "steamos-session-default" ''
              #!${pkgs.bash}

              echo -e '[Autologin]\nSession=steam' > /tmp/zz-steamos.conf
            ''}/bin/steamos-session-default";
          };
          restartIfChanged = false;
        };
      };
      tmpfiles.rules = [
        "L+ /etc/sddm.conf.d/01-nixos.conf - - - - ${config.environment.etc."sddm.conf".source}"
        "L+ /etc/sddm.conf.d/zz-steamos.conf - - - - /tmp/zz-steamos.conf"
      ];
    };

    system.activationScripts.sddmConf = {
      text = ''
        rm -f /etc/sddm.conf
      '';
    };

  };

}
