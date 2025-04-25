{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "foxflake-environment-selection";
  buildCommand = let
    script = pkgs.writeShellApplication {
      name = name;
      text = ''
set +o nounset
set -e

if [ -z "''${DISPLAY}" ]; then echo "Error: DISPLAY not found, please make sure you run this program from a desktop environment."; exit 1; fi

if ! ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Environment selection interface" --error --ok-label="Exit" --text "Internet connection is not available, please make sure you are connected to the internet before using this tool."; exit 1; fi

if [ ''${#} -eq 0 ]; then
	interface=1
elif [ ''${#} -eq 3 ]; then
	if { [ "''${1}" != "= \"gnome\"" ] && [ "''${1}" != "= \"plasma\"" ]; } || { [ "''${2}" != "= [ ]" ] && [ "''${2}" != "= [ \"standard\" ]" ] && [ "''${2}" != "= [ \"gaming\" ]" ] && [ "''${2}" != "= [ \"studio\" ]" ] && [ "''${2}" != "= [ \"standard\" \"gaming\" ]" ] && [ "''${2}" != "= [ \"standard\" \"studio\" ]" ] && [ "''${2}" != "= [ \"gaming\" \"studio\" ]" ] && [ "''${2}" != "= [ \"standard\" \"gaming\" \"studio\" ]" ]; } || { [ "''${3}" != "= true" ] && [ "''${3}" != "= false" ]; }; then
		${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Environment selection interface" --error --ok-label="Exit" --text "Error: Parameters are not valid, please specify FoxFlake environment, edition and whether Waydroid should be installed."
		exit 1
	else
		interface=0
	fi
else
	${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Environment selection interface" --error --ok-label="Exit" --text "Error: Please specify FoxFlake environment, edition and whether Waydroid should be installed."
	exit 1
fi

if [ "''${interface}" -eq 1 ]; then

	environment_options=( "Gnome" "Plasma" )
	bundles_options=( "Minimal" "Standard" "Gaming" "Studio" "Standard + Gaming" "Standard + Studio" "Gaming + Studio" "Full")
	waydroid_options=( "Yes" "No" )

	selected_environment=$(${pkgs.zenity}/bin/zenity --height=600 --width=800 --title="FoxFlake - Environment selection interface" --list --text "Welcome to the environment selection interface.\n\nWhich environment of FoxFlake would you like to use ?\n\nWarning: changing the environment will reset your dconf and gtk settings.\n" --column "Environment" "''${environment_options[@]}" --ok-label="Next" --cancel-label="Exit" 2>/dev/null)
	selected_bundles=$(${pkgs.zenity}/bin/zenity --height=600 --width=800 --title="FoxFlake - Environment selection interface" --list --text "Which bundles would you like to install ?" --column "Bundles" "''${bundles_options[@]}" --ok-label="Next" --cancel-label="Exit" 2>/dev/null)
	selected_waydroid=$(${pkgs.zenity}/bin/zenity --height=600 --width=800 --title="FoxFlake - Environment selection interface" --list --text "Do you want to install Waydroid ?" --column "Install Waydroid" "''${waydroid_options[@]}" --ok-label="Next" --cancel-label="Exit" 2>/dev/null)
	if [ -z "$selected_environment" ]; then exit 0; fi

	case $selected_environment in
		'Gnome')
			environment_short_name="= \"gnome\""
		;;
		'Plasma')
			environment_short_name="= \"plasma\""
		;;
	esac

	case $selected_bundles in
		'Minimal')
			bundles_short_name="= [ ]"
		;;
		'Standard')
			bundles_short_name="= [ \"standard\" ]"
		;;
		'Gaming')
			bundles_short_name="= [ \"gaming\" ]"
		;;
		'Studio')
			bundles_short_name="= [ \"studio\" ]"
		;;
		'Standard + Gaming')
			bundles_short_name="= [ \"standard\" \"gaming\" ]"
		;;
		'Standard + Studio')
			bundles_short_name="= [ \"standard\" \"studio\" ]"
		;;
		'Gaming + Studio')
			bundles_short_name="= [ \"gaming\" \"studio\" ]"
		;;
		'Full')
			bundles_short_name="= [ \"standard\" \"gaming\" \"studio\" ]"
		;;
	esac

	case $selected_waydroid in
		'Yes')
			waydroid_short_name="= true"
		;;
		'No')
			waydroid_short_name="= false"
		;;
	esac

	if ${pkgs.coreutils}/bin/test "x$(${pkgs.coreutils}/bin/id -u)" != "x0"; then
		pkexec --disable-internal-agent env DISPLAY="''${DISPLAY}" WAYLAND_DISPLAY="''${WAYLAND_DISPLAY}" XAUTHORITY="''${XAUTHORITY}" XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR}" "''${0}" "''${environment_short_name}" "''${bundles_short_name}" "''${waydroid_short_name}" || { ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Environment selection interface" --error --ok-label="Exit" --text "Failed to launch pkexec."; exit 1; }
	fi

else

	if ${pkgs.coreutils}/bin/test "x$(${pkgs.coreutils}/bin/id -u)" != "x0"; then
		pkexec --disable-internal-agent env DISPLAY="''${DISPLAY}" WAYLAND_DISPLAY="''${WAYLAND_DISPLAY}" XAUTHORITY="''${XAUTHORITY}" XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR}" "''${0}" "''${1}" "''${2}" "''${3}" || { ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Environment selection interface" --error --ok-label="Exit" --text "Failed to launch pkexec."; exit 1; }
	fi

	${pkgs.gnugrep}/bin/grep -q 'foxflake.environment.type =' /etc/nixos/configuration.nix || ! ${pkgs.gnugrep}/bin/grep -q 'foxflake.system.bundles =' /etc/nixos/configuration.nix || ! ${pkgs.gnugrep}/bin/grep -q 'foxflake.system.waydroid =' /etc/nixos/configuration.nix || { ${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Environment selection interface" --error --ok-label="Exit" --text "Cannot proceed due to an error in the FoxFlake configuration.nix."; exit 1; }

	current_environment=$(${pkgs.gnugrep}/bin/grep 'foxflake.environment.type =' /etc/nixos/configuration.nix | ${pkgs.coreutils}/bin/cut -d';' -f1 | ${pkgs.gnugrep}/bin/grep -o '=.*')
	current_bundles=$(${pkgs.gnugrep}/bin/grep 'foxflake.system.bundles =' /etc/nixos/configuration.nix | ${pkgs.coreutils}/bin/cut -d';' -f1 | ${pkgs.gnugrep}/bin/grep -o '=.*')
	current_waydroid=$(${pkgs.gnugrep}/bin/grep 'foxflake.system.waydroid =' /etc/nixos/configuration.nix | ${pkgs.coreutils}/bin/cut -d';' -f1 | ${pkgs.gnugrep}/bin/grep -o '=.*')
	
	${pkgs.gnused}/bin/sed -i "s@foxflake.environment.type.*;@foxflake.environment.type ''${1};@g" /etc/nixos/configuration.nix
	${pkgs.gnused}/bin/sed -i "s@foxflake.system.bundles.*;@foxflake.system.bundles ''${2};@g" /etc/nixos/configuration.nix
	${pkgs.gnused}/bin/sed -i "s@foxflake.system.waydroid.*;@foxflake.system.waydroid ''${3};@g" /etc/nixos/configuration.nix

	${pkgs.nixos-rebuild}/bin/nixos-rebuild boot || { \
		${pkgs.gnused}/bin/sed -i "s@foxflake.environment.type.*;@foxflake.environment.type ''${current_environment};@g" /etc/nixos/configuration.nix; \
		${pkgs.gnused}/bin/sed -i "s@foxflake.system.bundles.*;@foxflake.system.bundles ''${current_bundles};@g" /etc/nixos/configuration.nix; \
		${pkgs.gnused}/bin/sed -i "s@foxflake.system.waydroid.*;@foxflake.system.waydroid ''${current_waydroid};@g" /etc/nixos/configuration.nix; \
		${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Environment selection interface" --error --ok-label="Exit" --text "FoxFlake could not be rebuilt, configuration changes have been reverted."; \
		exit 1; \
	}

	if [ "''${current_environment}" != "''${1}" ]; then
		for gtkconfig in /home/*/.gtkrc* /home/*/.config/gtkrc* /home/*/.config/gtk-* /home/*/.config/dconf; do ${pkgs.coreutils}/bin/rm -rf "''${gtkconfig}"; done
	fi

	${pkgs.sudo}/bin/sudo --preserve-env=DISPLAY,WAYLAND_DISPLAY,XAUTHORITY,XDG_RUNTIME_DIR -u "$(${pkgs.coreutils}/bin/id -nu "''${PKEXEC_UID}")" ${pkgs.zenity}/bin/zenity --width=800 --title="FoxFlake - Environment selection interface" --info --ok-label="Exit" --text "The system has been updated. Changes will be applied on the next boot."

fi
      '';
    };
    desktopEntry = pkgs.makeDesktopItem {
      name = name;
      desktopName = "FoxFlake Environment Selection";
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
