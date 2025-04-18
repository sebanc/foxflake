{ pkgs }:
pkgs.stdenv.mkDerivation rec {
  name = "foxflake-environment-selection";
  buildCommand = let
    script = pkgs.writeShellApplication {
      name = name;
      text = ''
set +o nounset
set -e

if ! ${pkgs.curl}/bin/curl -L https://github.com/sebanc/foxflake > /dev/null 2>&1; then read -rp "Internet connection not available, please make sure you are connected to the internet."; exit 1; fi

if [ ''${#} -eq 0 ]; then
	interface=1
elif [ ''${#} -eq 3 ]; then
	if { [ "''${1}" != "= \"gnome\"" ] && [ "''${1}" != "= \"plasma\"" ]; } || { [ "''${2}" != "= [ ]" ] && [ "''${2}" != "= [ \"standard\" ]" ] && [ "''${2}" != "= [ \"gaming\" ]" ] && [ "''${2}" != "= [ \"studio\" ]" ] && [ "''${2}" != "= [ \"standard\" \"gaming\" ]" ] && [ "''${2}" != "= [ \"standard\" \"studio\" ]" ] && [ "''${2}" != "= [ \"gaming\" \"studio\" ]" ] && [ "''${2}" != "= [ \"standard\" \"gaming\" \"studio\" ]" ]; } || { [ "''${3}" != "= true" ] && [ "''${3}" != "= false" ]; }; then
		read -rp "Error: FoxFlake environment and / or edition parameters are not valid."
		exit 1
	else
		interface=0
	fi
else
	echo "Error: Please specify both FoxFlake environment and edition."
	exit 1
fi

if [ "''${interface}" -eq 1 ]; then

	environment_options=( "FALSE" "Gnome" "FALSE" "Plasma" )
	bundles_options=( "FALSE" "Minimal" "FALSE" "Standard" "FALSE" "Gaming" "FALSE" "Studio" "FALSE" "Standard + Gaming" "FALSE" "Standard + Studio" "FALSE" "Gaming + Studio" "FALSE" "Full")
	waydroid_options=( "FALSE" "Yes" "FALSE" "No" )

	selected_environment=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="FoxFlake - Environment selection interface" --list --radiolist --text "Welcome to the environment selection interface.\n\nWhich environment of FoxFlake would you like to use ?\n\nWarning: changing the environment will reset your dconf and gtk settings.\n" --column "Selection" --column "Environment" "''${environment_options[@]}" --ok-label="Next" --cancel-label="Exit" 2>/dev/null)
	selected_bundles=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="FoxFlake - Environment selection interface" --list --radiolist --text "Which bundles would you like to install ?" --column "Selection" --column "Bundles" "''${bundles_options[@]}" --ok-label="Next" --cancel-label="Exit" 2>/dev/null)
	selected_waydroid=$(${pkgs.zenity}/bin/zenity --height=480 --width=640 --title="FoxFlake - Environment selection interface" --list --radiolist --text "Do you want to install Waydroid ?" --column "Selection" --column "Install Waydroid" "''${waydroid_options[@]}" --ok-label="Next" --cancel-label="Exit" 2>/dev/null)
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
		pkexec --disable-internal-agent "''${0}" "''${environment_short_name}" "''${bundles_short_name}" "''${waydroid_short_name}"
		status=$?
		exit $status
	fi

else

	if ${pkgs.coreutils}/bin/test "x$(${pkgs.coreutils}/bin/id -u)" != "x0"; then
		pkexec --disable-internal-agent "''${0}" "''${1}" "''${2}" "''${3}"
		status=$?
		exit $status
	fi

	if ! ${pkgs.gnugrep}/bin/grep -q 'foxflake.environment.type =' /etc/nixos/configuration.nix || ! ${pkgs.gnugrep}/bin/grep -q 'foxflake.system.bundles =' /etc/nixos/configuration.nix || ! ${pkgs.gnugrep}/bin/grep -q 'foxflake.system.waydroid =' /etc/nixos/configuration.nix; then read -rp "FoxFlake standard configuration is missing required options. Cannot proceed."; exit 1; fi

	current_environment=$(${pkgs.gnugrep}/bin/grep 'foxflake.environment.type =' /etc/nixos/configuration.nix | ${pkgs.coreutils}/bin/cut -d';' -f1 | ${pkgs.gnugrep}/bin/grep -o '=.*')
	current_bundles=$(${pkgs.gnugrep}/bin/grep 'foxflake.system.bundles =' /etc/nixos/configuration.nix | ${pkgs.coreutils}/bin/cut -d';' -f1 | ${pkgs.gnugrep}/bin/grep -o '=.*')
	current_waydroid=$(${pkgs.gnugrep}/bin/grep 'foxflake.system.waydroid =' /etc/nixos/configuration.nix | ${pkgs.coreutils}/bin/cut -d';' -f1 | ${pkgs.gnugrep}/bin/grep -o '=.*')
	
	${pkgs.gnused}/bin/sed -i "s@foxflake.environment.type.*;@foxflake.environment.type ''${1};@g" /etc/nixos/configuration.nix
	${pkgs.gnused}/bin/sed -i "s@foxflake.system.bundles.*;@foxflake.system.bundles ''${2};@g" /etc/nixos/configuration.nix
	${pkgs.gnused}/bin/sed -i "s@foxflake.system.waydroid.*;@foxflake.system.waydroid ''${3};@g" /etc/nixos/configuration.nix

	${pkgs.nixos-rebuild}/bin/nixos-rebuild boot || { \
		${pkgs.gnused}/bin/sed "s@foxflake.environment.type.*;@foxflake.environment.type ''${current_environment};@g" /etc/nixos/configuration.nix; \
		${pkgs.gnused}/bin/sed "s@foxflake.system.bundles.*;@foxflake.system.bundles ''${current_bundles};@g" /etc/nixos/configuration.nix; \
		${pkgs.gnused}/bin/sed "s@foxflake.system.waydroid.*;@foxflake.system.waydroid ''${current_waydroid};@g" /etc/nixos/configuration.nix; \
		echo ""; read -rp "Error: FoxFlake update failed."; \
		exit 1; \
	}

	if [ "''${current_environment}" != "''${1}" ]; then
		for gtkconfig in /home/*/.gtkrc* /home/*/.config/gtkrc* /home/*/.config/gtk-* /home/*/.config/dconf; do ${pkgs.coreutils}/bin/rm -rf "''${gtkconfig}"; done
	fi

	echo ""; read -rp "The system has been updated. Changes will be applied on the next boot."

fi
      '';
    };
    desktopEntry = pkgs.makeDesktopItem {
      name = name;
      desktopName = "FoxFlake Environment Selection";
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
