{ lib, config, pkgs, inputs, ... }:

{

  nixpkgs.overlays = [
    (final: prev: {
      gamescope-foxflake = let
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = final.stdenv.hostPlatform.system;
          config = final.config;
        };
      in
      (pkgs-unstable.gamescope.override {
        enableWsi = true;
      }).overrideAttrs (old: rec {
        patches = (old.patches or []) ++ [
          (final.writeText "foxflake-specific.patch" ''
            --- a/src/steamcompmgr.cpp      2026-04-12 11:04:10.709969160 +0200
            +++ b/src/steamcompmgr.cpp      2026-04-12 20:20:53.296661240 +0200
            @@ -3654,6 +3654,16 @@
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
    })
  ];

}
