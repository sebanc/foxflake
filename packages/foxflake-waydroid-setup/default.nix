{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "foxflake-waydroid-setup";
  buildCommand = let
    script = pkgs.writeShellApplication {
      name = name;
      bashOptions = [ "errexit" "pipefail" ];
      text = ''
set -e

if [ -z "''${DISPLAY}" ]; then echo "Error: DISPLAY not found, please make sure you run this program from a desktop environment."; exit 1; fi

if ! ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Internet connection is not available, please make sure you are connected to the internet before using this tool." 2>/dev/null; exit 1; fi

if [ ''${#} -eq 0 ]; then
	interface=1
elif [ ''${#} -eq 1 ]; then
	if { [ "''${1}" != "VANILLA" ] && [ "''${1}" != "GAPPS" ]; }; then
		${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Error: Waydroid variant is not valid." 2>/dev/null
		exit 1
	else
		interface=0
	fi
else
	${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Error: Please specify the Waydroid variant you want to install." 2>/dev/null
	exit 1
fi

if [ "''${interface}" -eq 1 ]; then

	waydroid_variants=( "VANILLA" "GAPPS" )

	selected_variant=$(${pkgs.zenity}/bin/zenity --height=600 --width=800 --title="FoxFlake - Waydroid setup" --list --text "Welcome to the Waydroid setup script, which Waydroid variant would you like to install ?" --column "Variant" "''${waydroid_variants[@]}" --ok-label="Install" --cancel-label="Exit" 2>/dev/null)
	if [ -z "$selected_variant" ]; then exit 0; fi

	if ${pkgs.coreutils}/bin/test "x$(${pkgs.coreutils}/bin/id -u)" != "x0"; then
		pkexec --disable-internal-agent env DISPLAY="''${DISPLAY}" WAYLAND_DISPLAY="''${WAYLAND_DISPLAY}" XAUTHORITY="''${XAUTHORITY}" XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR}" "''${0}" "''${selected_variant}"
	fi

else

	if ${pkgs.coreutils}/bin/test "x$(${pkgs.coreutils}/bin/id -u)" != "x0"; then
		pkexec --disable-internal-agent env DISPLAY="''${DISPLAY}" WAYLAND_DISPLAY="''${WAYLAND_DISPLAY}" XAUTHORITY="''${XAUTHORITY}" XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR}" "''${0}" "''${1}"
	fi

	echo "Installing Waydroid."

	${pkgs.systemd}/bin/systemctl stop waydroid-container.service || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Failed to stop waydroid-container.service." 2>/dev/null; exit 1; }

	sleep 5

	${pkgs.coreutils}/bin/rm -rf /var/lib/waydroid /home/*/.local/share/waydroid /home/*/.local/share/applications/*aydroid*

	${pkgs.unstable.waydroid}/bin/waydroid init -s "''${1}" || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Failed to init waydroid." 2>/dev/null; exit 1; }

	if [ -d /sys/class/drm/renderD128 ] && [ -d /sys/class/drm/renderD129 ] && { [ "$(${pkgs.coreutils}/bin/realpath /sys/class/drm/renderD128/device/driver)" == "/sys/bus/pci/drivers/nvidia" ] || [ "$(${pkgs.coreutils}/bin/realpath /sys/class/drm/renderD128/device/driver)" == "/sys/bus/pci/drivers/nouveau" ]; }; then
		${pkgs.gnused}/bin/sed -i -z 's@\n\[properties]@drm_device = /dev/dri/renderD129\n\n\[properties]@g' /var/lib/waydroid/waydroid.cfg
		if [ "$(${pkgs.coreutils}/bin/realpath /sys/class/drm/renderD129/device/driver)" == "/sys/bus/pci/drivers/amdgpu" ]; then arm_translation="libndk"; fi
	elif ${pkgs.gnugrep}/bin/grep -q 'QEMU' /sys/class/dmi/id/chassis_vendor; then
		echo -e "ro.hardware.gralloc=default\nro.hardware.egl=swiftshader" >> /var/lib/waydroid/waydroid.cfg
	else
		if [ "$(${pkgs.coreutils}/bin/realpath /sys/class/drm/renderD128/device/driver)" == "/sys/bus/pci/drivers/amdgpu" ]; then arm_translation="libndk"; fi
	fi
	echo -e "persist.waydroid.multi_windows=true" >> /var/lib/waydroid/waydroid.cfg
	if [ -z "''${arm_translation}" ]; then arm_translation="libhoudini"; fi

	echo ""
	echo "Installing ''${arm_translation} and widevine."
	${pkgs.coreutils}/bin/rm -rf /tmp/waydroid_script
	${pkgs.git}/bin/git clone -b main https://github.com/casualsnek/waydroid_script.git /tmp/waydroid_script || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Failed to clone waydroid_script git repository." 2>/dev/null; exit 1; }
	${pkgs.nix}/bin/nix-shell -p bash -p curl -p gnupg -p lzip -p util-linux -p unzip -p xz -p python3 -p python3Packages.inquirerpy -p python3Packages.requests -p python3Packages.tqdm --run "/tmp/waydroid_script/main.py install ''${arm_translation} widevine" || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "waydroid_script failed to install ''${arm_translation} and widevine." 2>/dev/null; exit 1; }

	${pkgs.unstable.waydroid}/bin/waydroid upgrade -o || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Failed to add waydroid options." 2>/dev/null; exit 1; }
	${pkgs.systemd}/bin/systemctl restart waydroid-container.service || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Failed to restart waydroid-container.service." 2>/dev/null; exit 1; }

	if [  "''${1}" == "GAPPS" ]; then
		${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.unstable.waydroid}/bin/waydroid session start > /dev/null 2>&1 &
		echo "Please wait..."
		sleep 30
		registration_text="$(${pkgs.coreutils}/bin/mktemp)"
		echo -e "\nWaydroid had been installed with gapps, the recommended arm translation layer for your device and widevine support, additional features (Magisk, Tweaks...) can be installed with the waydroid-helper program.\n\nIn order to use the playstore you will first need to register the android_id \"$(echo 'ANDROID_RUNTIME_ROOT=/apex/com.android.runtime ANDROID_DATA=/data ANDROID_TZDATA_ROOT=/apex/com.android.tzdata ANDROID_I18N_ROOT=/apex/com.android.i18n sqlite3 /data/data/com.google.android.gsf/databases/gservices.db "select * from main where name = \"android_id\";"' | ${pkgs.unstable.waydroid}/bin/waydroid shell | cut -d'|' -f2 || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Failed to get the android_id, please try again." 2>/dev/null; exit 1; })\" with your google account at:\nhttps://www.google.com/android/uncertified\n\nOnce done, please finalize the setup by clicking \"Restart Waydroid\"." > "''${registration_text}"
		${pkgs.systemd}/bin/systemctl stop waydroid-container.service || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Failed to stop waydroid-container.service." 2>/dev/null; exit 1; }
		${pkgs.coreutils}/bin/chmod 0644 "''${registration_text}"
		if ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --height=600 --width=800 --title="FoxFlake - Waydroid setup" --text-info --filename="''${registration_text}" --ok-label="Restart Waydroid" --cancel-label="Cancel" 2>/dev/null; then
			${pkgs.coreutils}/bin/rm -f "''${registration_text}"
			${pkgs.systemd}/bin/systemctl restart waydroid-container.service || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Waydroid setup" --error --ok-label="Exit" --text "Failed to restart waydroid-container.service." 2>/dev/null; exit 1; }
		else
			${pkgs.coreutils}/bin/rm -rf "''${registration_text}" /var/lib/waydroid /home/*/.local/share/waydroid /home/*/.local/share/applications/*aydroid*
		fi
	else
		${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --height=600 --width=800 --title="FoxFlake - Waydroid setup" --info --ok-label="Exit" --text "\nWaydroid had been installed with the recommended arm translation layer for your device and widevine support, additional features (Magisk, Tweaks...) can be installed with the waydroid-helper program." --ok-label="Exit" 2>/dev/null
	fi
fi
      '';
    };
    desktopEntry = pkgs.makeDesktopItem {
      name = name;
      desktopName = "FoxFlake Waydroid setup";
      icon = "foxflake-icon-light";
      exec = "${script}/bin/${name}";
      terminal = true;
      categories = ["Utility"];
    };
  in ''
    mkdir -p $out/bin
    cp ${script}/bin/${name} $out/bin
    mkdir -p $out/share/applications
    cp ${desktopEntry}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
  '';
  dontBuild = true;
}
