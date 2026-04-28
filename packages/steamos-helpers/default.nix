{ lib, config, pkgs, ... }:

{

  nixpkgs.overlays = [
    (final: prev: {
      steamos-helpers = prev.symlinkJoin {
        name = "steamos-helpers";
        passthru.providedSessions = [ "steam" ];
        paths = [
          (prev.writeShellApplication {
            name = "steamos-priv-write";
            bashOptions = [ "errexit" "pipefail" ];
            text = ''
WRITE_PATH="$1"
WRITE_VALUE="$2"

function CommitWrite()
{
    echo "commit: $WRITE_VALUE -> $WRITE_PATH" | systemd-cat -t p-steamos-priv-write -p warning
    echo "$WRITE_VALUE" > "$WRITE_PATH"
    chmod a+w "$WRITE_PATH"
    exit 0
}

function DeclineWrite()
{
    echo "decline: $WRITE_VALUE -> $WRITE_PATH" | systemd-cat -t p-steamos-priv-write -p err
    echo "$WRITE_VALUE" > "$WRITE_PATH"
    exit 1
}

echo "checking: $WRITE_PATH" | systemd-cat -t p-steamos-priv-write -p warning
if [[ "$WRITE_PATH" == /sys/class/backlight/*/brightness ]]; then
   CommitWrite
fi

DeclineWrite
            '';
          })
          (prev.writeShellApplication {
            name = "steamos-reboot-now";
            bashOptions = [ "errexit" "pipefail" ];
            text = ''
reboot
            '';
          })
          (prev.writeShellApplication {
            name = "steamos-poweroff-now";
            bashOptions = [ "errexit" "pipefail" ];
            text = ''
poweroff
            '';
          })
          (prev.writeShellApplication {
            name = "steam-session";
            bashOptions = [ "pipefail" ];
            excludeShellChecks = [ "SC2010" "SC2050" "SC2086" "SC2089" "SC2090" "SC2155" ];
            text = ''
##
## Script to detect the display / GPU to use with gamescope
##

if [ ! -z "''${GAMESCOPE_SESSION_DISPLAY}" ]; then
        custom_gpu="$(ls /sys/bus/*/devices/*/drm/card*/card*-* | grep "\-''${GAMESCOPE_SESSION_DISPLAY}:$" | cut -d'/' -f8)"
        if [ ! -z "''${custom_gpu}" ]; then
                GAMESCOPE_SESSION_GPU="$(cat /sys/class/drm/"''${custom_gpu}"/device/vendor | sed 's@0x@@g'):$(cat /sys/class/drm/"''${custom_gpu}"/device/device | sed 's@0x@@g')"
        else
                unset GAMESCOPE_SESSION_DISPLAY
                echo "# Falling back to display autodetection as GAMESCOPE_SESSION_DISPLAY is incorrect."
        fi
fi

if [ -z "''${GAMESCOPE_SESSION_DISPLAY}" ]; then
        preferred_gpu=$(grep 'enabled' /sys/bus/*/devices/*/drm/card*/card*-*/enabled | cut -d'/' -f8 | sort -r | uniq | head -1)
        GAMESCOPE_SESSION_GPU="$(cat /sys/class/drm/"''${preferred_gpu}"/device/vendor | sed 's@0x@@g')":"$(cat /sys/class/drm/"''${preferred_gpu}"/device/device | sed 's@0x@@g')"
        active_displays="$(grep 'enabled' /sys/class/drm/"''${preferred_gpu}"/"''${preferred_gpu}"-*/enabled | cut -d':' -f1 | cut -d'/' -f-6)"
        default_display=$(echo "$active_displays" | head -1)
        for display in ''${active_displays}; do if [ -z "''${GAMESCOPE_SESSION_DISPLAY}" ] && [ "$(echo "''${display}" | cut -d'/' -f6 | cut -d'-' -f2)" == "HDMI" ]; then GAMESCOPE_SESSION_DISPLAY="$(echo "''${display}" | cut -d'/' -f6 | cut -d'-' -f2-)"; fi; done
        for display in ''${active_displays}; do if [ -z "''${GAMESCOPE_SESSION_DISPLAY}" ] && [ "$(echo "''${display}" | cut -d'/' -f6 | cut -d'-' -f2)" == "DP" ]; then GAMESCOPE_SESSION_DISPLAY="$(echo "''${display}" | cut -d'/' -f6 | cut -d'-' -f2-)"; fi; done
        for display in ''${active_displays}; do if [ -z "''${GAMESCOPE_SESSION_DISPLAY}" ] && [ "$(echo "''${display}" | cut -d'/' -f6 | cut -d'-' -f2)" == "DVI" ]; then GAMESCOPE_SESSION_DISPLAY="$(echo "''${display}" | cut -d'/' -f6 | cut -d'-' -f2-)"; fi; done
        for display in ''${active_displays}; do if [ -z "''${GAMESCOPE_SESSION_DISPLAY}" ] && [ "$(echo "''${display}" | cut -d'/' -f6 | cut -d'-' -f2)" == "VGA" ]; then GAMESCOPE_SESSION_DISPLAY="$(echo "''${display}" | cut -d'/' -f6 | cut -d'-' -f2-)"; fi; done
        if [ -z "''${GAMESCOPE_SESSION_DISPLAY}" ]; then GAMESCOPE_SESSION_DISPLAY="$(echo "''${default_display}" | cut -d'/' -f6 | cut -d'-' -f2-)"; fi
fi

if [ ! -z "''${GAMESCOPE_SESSION_GPU}" ] && [ ! -z "''${GAMESCOPE_SESSION_DISPLAY}" ]; then
        GAMESCOPE_FLAGS="''${GAMESCOPE_FLAGS} --prefer-vk-device ''${GAMESCOPE_SESSION_GPU} -O ''${GAMESCOPE_SESSION_DISPLAY},'*'"
fi

if [ ! -z "''${GAMESCOPE_SESSION_RESOLUTION}" ]; then
        GAMESCOPE_SESSION_WIDTH="$(echo "''${GAMESCOPE_SESSION_RESOLUTION}" | cut -d'x' -f1)"
        GAMESCOPE_SESSION_HEIGHT="$(echo "''${GAMESCOPE_SESSION_RESOLUTION}" | cut -d'x' -f2)"
        GAMESCOPE_SESSION_RERESH_RATE="$(echo "''${GAMESCOPE_SESSION_RESOLUTION}" | cut -d'x' -f3)"
fi

if [ ! -z "''${GAMESCOPE_SESSION_WIDTH}" ] && [ ! -z "''${GAMESCOPE_SESSION_HEIGHT}" ] && [ ! -z "''${GAMESCOPE_SESSION_RERESH_RATE}" ]; then
        GAMESCOPE_FLAGS="''${GAMESCOPE_FLAGS} -w ''${GAMESCOPE_SESSION_WIDTH} -h ''${GAMESCOPE_SESSION_HEIGHT} -r ''${GAMESCOPE_SESSION_RERESH_RATE}"
fi

if [ ! -z "''${GAMESCOPE_SESSION_UPSCALE}" ]; then
        GAMESCOPE_SESSION_UPSCALE_WIDTH="$(echo "''${GAMESCOPE_SESSION_UPSCALE}" | cut -d'x' -f1)"
        GAMESCOPE_SESSION_UPSCALE_HEIGHT="$(echo "''${GAMESCOPE_SESSION_UPSCALE}" | cut -d'x' -f2)"
fi

if [ ! -z "''${GAMESCOPE_SESSION_UPSCALE_WIDTH}" ] && [ ! -z "''${GAMESCOPE_SESSION_UPSCALE_HEIGHT}" ]; then
        GAMESCOPE_FLAGS="''${GAMESCOPE_FLAGS} -W ''${GAMESCOPE_SESSION_UPSCALE_WIDTH} -H ''${GAMESCOPE_SESSION_UPSCALE_HEIGHT}"
fi

if [ ! -z "''${GAMESCOPE_SESSION_HDR}" ]; then
        GAMESCOPE_FLAGS="''${GAMESCOPE_FLAGS} --hdr-enabled"
fi

if [ "${config.foxflake.environment.type}" == "steamdeck" ]; then
	GAMESCOPE_FLAGS="''${GAMESCOPE_FLAGS} --mangoapp"
        STEAM_FLAGS="''${STEAM_FLAGS} -steamdeck"
fi

##
## SteamOS session globals
##

export ENABLE_GAMESCOPE_WSI=1
export GAMESCOPE_NV12_COLORSPACE=k_EStreamColorspace_BT601
export GTK_IM_MODULE=Steam
export GTK_USE_PORTAL=1
export INTEL_DEBUG=noccs,norbc
export QT_IM_MODULE=steam
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORM_THEME=kde
export R600_DEBUG=nodcc
export XCURSOR_SIZE=48
export XDG_CURRENT_DESKTOP=KDE
export XKB_DEFAULT_LAYOUT=${config.foxflake.internationalisation.keyboard.layout}
export XKB_DEFAULT_VARIANT=${config.foxflake.internationalisation.keyboard.variant}

if [ ! -d "''${HOME}/.local/share/Steam" ]; then
	xvfb-run steam ''${STEAM_FLAGS} -skipinitialbootstrap -exitsteam | gamescope ''${GAMESCOPE_FLAGS} --backend drm -- zenity --width 400 --height 200 --progress --title="Steam first boot setup" --text="Preparing Steam for initial boot... Please wait, this can take a few minutes." --pulsate --auto-close
fi

__NV_PRIME_RENDER_OFFLOAD=1 /run/wrappers/bin/gamescope ''${GAMESCOPE_FLAGS} --backend drm --borderless --default-touch-mode 4 --force-grab-cursor --fullscreen --hide-cursor-delay 3000 --steam -- bash -c "steam ''${STEAM_FLAGS} -cef-force-gpu -gamepadui -steamos3 -no-child-update-ui" > /tmp/gamescope_log.txt 2>&1
            '';
          })
          (prev.writeTextFile {
            name = "steamos-polkit-policy";
            destination = "/share/polkit-1/actions/org.valve.steamos.policy";
            text = ''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE policyconfig PUBLIC
 "-//freedesktop//DTD PolicyKit Policy Configuration 1.0//EN"
 "http://www.freedesktop.org/standards/PolicyKit/1/policyconfig.dtd">
<policyconfig>

  <vendor>Valve SteamOS</vendor>
  <vendor_url>http://www.steampowered.com</vendor_url>

  <action id="org.valve.policykit.steamos.pkexec.run-steamos-polkit-helpers-steamos-priv-write">
    <description>Helper to write to a set of device nodes</description>
    <icon_name>package-x-generic</icon_name> 
    <defaults>
      <allow_any>yes</allow_any>
      <allow_inactive>yes</allow_inactive>
      <allow_active>yes</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/run/current-system/sw/bin/steamos-priv-write</annotate>
  </action>

  <action id="org.valve.policykit.steamos.pkexec.run-steamos-polkit-helpers-steamos-reboot-now">
    <description>Reboot system</description>
    <icon_name>package-x-generic</icon_name> 
    <defaults>
      <allow_any>yes</allow_any>
      <allow_inactive>yes</allow_inactive>
      <allow_active>yes</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/run/current-system/sw/bin/steamos-reboot-now</annotate>
  </action>

  <action id="org.valve.policykit.steamos.pkexec.run-steamos-polkit-helpers-steamos-poweroff-now">
    <description>Poweroff system</description>
    <icon_name>package-x-generic</icon_name> 
    <defaults>
      <allow_any>yes</allow_any>
      <allow_inactive>yes</allow_inactive>
      <allow_active>yes</allow_active>
    </defaults>
    <annotate key="org.freedesktop.policykit.exec.path">/run/current-system/sw/bin/steamos-poweroff-now</annotate>
  </action>

</policyconfig>
            '';
          })
          (prev.writeTextFile {
            name = "steam-session-desktop";
            destination = "/share/wayland-sessions/steam.desktop";
            text = ''
[Desktop Entry]
Encoding=UTF-8
Name=Steam
Comment=Steam gamescope session
Exec=steam-session
Icon=steamicon.png
Type=Application
DesktopNames=gamescope
            '';
          })
          (prev.runCommand "steamos-polkit-helpers" {} ''
mkdir -p $out/bin/steamos-polkit-helpers $out/lib
cat >$out/bin/atomupd-manager <<'ATOMUPDMANAGER'
#!/bin/bash

exit 0
ATOMUPDMANAGER
chmod 0755 $out/bin/atomupd-manager
cat >$out/bin/jupiter-controller-update <<'CONTROLLERUPDATE'
#!/bin/bash

exit 0
CONTROLLERUPDATE
chmod 0755 $out/bin/jupiter-controller-update
cat >$out/bin/jupiter-initial-firmware-update <<'INITIALFIRMWAREUPDATE'
#!/bin/bash

exit 0
INITIALFIRMWAREUPDATE
chmod 0755 $out/bin/jupiter-initial-firmware-update
cat >$out/bin/steamos-session-select <<'SESSIONSELECT'
#!/bin/bash

echo -e '[Autologin]\nSession=plasma' > /tmp/zz-steamos.conf

steam -shutdown
SESSIONSELECT
chmod 0755 $out/bin/steamos-session-select
cat >$out/bin/steamos-atomupd-client <<'ATOMUPDCLIENT'
#!/bin/bash

exit 0
ATOMUPDCLIENT
chmod 0755 $out/bin/steamos-atomupd-client
cat >$out/bin/steamos-atomupd-mkmanifest <<'ATOMUPDMKMANIFEST'
#!/bin/bash

exit 0
ATOMUPDMKMANIFEST
chmod 0755 $out/bin/steamos-atomupd-mkmanifest
cat >$out/bin/steamos-select-branch <<'SELECTBRANCH'
#!/bin/bash

set -eu

if [[ $# -eq 1 ]]; then
  case "$1" in
    "-c")
      echo rel
      exit 0
      ;;
    "-l")
      echo rel
      exit 0
      ;;
    *)
      exit 0
      ;;
  esac
fi
SELECTBRANCH
chmod 0755 $out/bin/steamos-select-branch
cat >$out/bin/steamos-update <<'FAKESTEAMOSUPDATE'
#!/bin/bash

set -eu

exit 7
FAKESTEAMOSUPDATE
chmod 0755 $out/bin/steamos-update
cat >$out/bin/steamos-update-os <<'FAKESTEAMOSUPDATEOS'
#!/bin/bash

set -eu

exit 0
FAKESTEAMOSUPDATEOS
chmod 0755 $out/bin/steamos-update-os
cat >$out/bin/steamos-polkit-helpers/steamos-select-branch <<'SELECTBRANCH'
#!/bin/bash

set -eu

steamos-select-branch
SELECTBRANCH
chmod 0755 $out/bin/steamos-polkit-helpers/steamos-select-branch
cat >$out/bin/steamos-polkit-helpers/steamos-update <<'FAKESTEAMOSUPDATE'
#!/bin/bash

set -eu

steamos-update
FAKESTEAMOSUPDATE
chmod 0755 $out/bin/steamos-polkit-helpers/steamos-update
cat >$out/bin/steamos-polkit-helpers/steamos-set-hostname <<'SETHOSTNAME'
#!/bin/bash

set -eu

exit 1
SETHOSTNAME
chmod 0755 $out/bin/steamos-polkit-helpers/steamos-set-hostname
cat >$out/bin/steamos-polkit-helpers/steamos-set-timezone <<'SETTIMEZONE'
#!/bin/bash

set -eu

exit 1
SETTIMEZONE
chmod 0755 $out/bin/steamos-polkit-helpers/steamos-set-timezone
cat >$out/bin/steamos-polkit-helpers/steamos-priv-write <<'PRIVWRITE'
#!/bin/bash

set -eu

exec pkexec --disable-internal-agent "/run/current-system/sw/bin/steamos-priv-write" "$@"
PRIVWRITE
chmod 0755 $out/bin/steamos-polkit-helpers/steamos-priv-write
cat >$out/bin/steamos-polkit-helpers/steamos-reboot-now <<'REBOOT'
#!/bin/bash

set -e

exec pkexec --disable-internal-agent "/run/current-system/sw/bin/steamos-reboot-now" "$@"
REBOOT
chmod 0755 $out/bin/steamos-polkit-helpers/steamos-reboot-now
cat >$out/bin/steamos-polkit-helpers/steamos-poweroff-now <<'POWEROFF'
#!/bin/bash

set -e

exec pkexec --disable-internal-agent "/run/current-system/sw/bin/steamos-poweroff-now" "$@"
POWEROFF
chmod 0755 $out/bin/steamos-polkit-helpers/steamos-poweroff-now
cat >$out/bin/steamos-polkit-helpers/steamos-enable-sshd <<'ENABLESSHD'
#!/bin/bash

set -eu

exit 1
ENABLESSHD
chmod 0755 $out/bin/steamos-polkit-helpers/steamos-enable-sshd
cat >$out/bin/steamos-polkit-helpers/jupiter-biosupdate <<'FAKEBIOSUPDATE'
#!/bin/bash

exit 0
FAKEBIOSUPDATE
chmod 0755 $out/bin/steamos-polkit-helpers/jupiter-biosupdate
cat >$out/bin/steamos-polkit-helpers/jupiter-check-support <<'FAKESUPPORT'
#!/bin/bash

exit 1
FAKESUPPORT
chmod 0755 $out/bin/steamos-polkit-helpers/jupiter-check-support
cat >$out/bin/steamos-polkit-helpers/jupiter-dock-updater <<'FAKEDOCKUPDATE'
#!/bin/bash

exit 7
FAKEDOCKUPDATE
chmod 0755 $out/bin/steamos-polkit-helpers/jupiter-dock-updater
          '')
        ];
      };
    })
  ];

}
