{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "foxflake-waydroid-setup";
  buildCommand = let
    script = pkgs.writeShellApplication {
      name = name;
      text = ''
set +o nounset
set -e

if ! ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then read -rp "Internet connection not available, please make sure you are connected to the internet."; exit 1; fi

if [ ''${#} -eq 0 ]; then
	interface=1
elif [ ''${#} -eq 1 ]; then
	if { [ "''${1}" != "VANILLA" ] && [ "''${1}" != "GAPPS" ]; }; then
		read -rp "Error: Waydroid variant is not valid."
		exit 1
	else
		interface=0
	fi
else
	echo "Error: Please specify the Waydroid variant you want to install."
	exit 1
fi

if [ "''${interface}" -eq 1 ]; then

	waydroid_variants=( "FALSE" "VANILLA" "FALSE" "GAPPS" )

	selected_variant=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="FoxFlake Waydroid setup" --list --radiolist --text "Welcome to the Waydroid setup script, which Waydroid variant would you like to install ?" --column "Selection" --column "Variant" "''${waydroid_variants[@]}" --ok-label="Install" --cancel-label="Exit" 2>/dev/null)
	if [ -z "$selected_variant" ]; then exit 0; fi

	if ${pkgs.coreutils}/bin/test "x$(${pkgs.coreutils}/bin/id -u)" != "x0"; then
		pkexec --disable-internal-agent "''${0}" "''${selected_variant}"
		status=$?
		exit $status
	fi

else

	if ${pkgs.coreutils}/bin/test "x$(${pkgs.coreutils}/bin/id -u)" != "x0"; then
		pkexec --disable-internal-agent "''${0}" "''${1}"
		status=$?
		exit $status
	fi

	${pkgs.unstable.waydroid}/bin/waydroid session stop > /dev/null 2>&1
	${pkgs.unstable.waydroid}/bin/waydroid container stop > /dev/null 2>&1

	sleep 5

	${pkgs.coreutils}/bin/rm -rf /var/lib/waydroid

	${pkgs.unstable.waydroid}/bin/waydroid init -s "''${1}"

	if [ -d /sys/class/drm/renderD128 ] && [ -d /sys/class/drm/renderD129 ] && { [ "$(${pkgs.coreutils}/bin/realpath /sys/class/drm/renderD128/device/driver)" == "/sys/bus/pci/drivers/nvidia" ] || [ "$(${pkgs.coreutils}/bin/realpath /sys/class/drm/renderD128/device/driver)" == "/sys/bus/pci/drivers/nouveau" ]; }; then
		${pkgs.gnused}/bin/sed -i -z 's@\n\[properties]@drm_device = /dev/dri/renderD129\n\n\[properties]@g' /var/lib/waydroid/waydroid.cfg
	elif { [ -d /sys/class/drm/renderD128 ] && { [ "$(${pkgs.coreutils}/bin/realpath /sys/class/drm/renderD128/device/driver)" == "/sys/bus/pci/drivers/nvidia" ] || [ "$(${pkgs.coreutils}/bin/realpath /sys/class/drm/renderD128/device/driver)" == "/sys/bus/pci/drivers/nouveau" ]; }; } || ${pkgs.gnugrep}/bin/grep -q 'qemu' /etc/nixos/hardware-configuration.nix; then
		echo -e "ro.hardware.gralloc=default\nro.hardware.egl=swiftshader" >> /var/lib/waydroid/waydroid.cfg
	fi
	echo -e "persist.waydroid.multi_windows=true" >> /var/lib/waydroid/waydroid.cfg

	${pkgs.unstable.waydroid}/bin/waydroid upgrade -o

	echo ""
	read -rp "Setup is finished, you can now start waydroid. You can also install complementary features (ARM translation tools, Tweaks...) with the waydroid-helper program."
fi
      '';
    };
    desktopEntry = pkgs.makeDesktopItem {
      name = name;
      desktopName = "FoxFlake Waydroid setup";
      icon = "foxflake-icon-dark";
      exec = "${script}/bin/${name}";
      terminal = true;
      categories = ["Utilities"];
    };
  in ''
    mkdir -p $out/bin
    cp ${script}/bin/${name} $out/bin
    mkdir -p $out/share/applications
    cp ${desktopEntry}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
  '';
  dontBuild = true;
}
