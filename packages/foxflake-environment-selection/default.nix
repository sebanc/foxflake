{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      foxflake-environment-selection = self.stdenv.mkDerivation rec {
        name = "foxflake-environment-selection";
        buildCommand = let
          script = self.writeShellApplication {
            name = name;
            runtimeInputs = with pkgs; [ 
              glib-networking
              gtk3
              (self.python3.withPackages (module: [ module.bottle module.pygobject3 module.proxy-tools module.pywebview module.typing-extensions ]))
              webkitgtk_4_1
            ];
            bashOptions = [ "errexit" "pipefail" ];
            excludeShellChecks = [ "SC2028" ];
            text = ''
set -e

if [ ! -f /etc/nixos/configuration.nix ]; then

	echo "NixOS configuration not found."
	exit 1

elif [ ''${#} -eq 0 ]; then

	if ! ${self.coreutils}/bin/id -Gn | ${self.gnugrep}/bin/grep -q "\bwheel\b"; then
		${self.zenity}/bin/zenity --error --title="FoxFlake environment selection" --text="This application is only available to users with admin privileges."
		exit 1
	fi

	foxflake_environment_selection_gui="$(mktemp /tmp/${name}-XXXXXXXX)"
	${self.coreutils}/bin/cat >"''${foxflake_environment_selection_gui}" <<'FOXFLAKE_GUI'
import argparse
import os
import sys
import webview

"""
FoxFlake environment selection app made with pywebview
"""

parser = argparse.ArgumentParser()
parser.add_argument('-aa', '--availableapplications', required=True, help="List of available Applications")
parser.add_argument('-ad', '--availabledesktops', required=True, help="List of available Desktop Environments")
parser.add_argument('-ca', '--currentapplications', required=True, help="Currently installed Applications")
parser.add_argument('-cd', '--currentdesktop', required=True, help="Currently installed Desktop Environment")
args = parser.parse_args()

html = """
<!DOCTYPE html>
<html>
<head lang="en">
<meta charset="UTF-8">
<style>
body {
  background: #f4f4f5;
  color: #2d2d2e;
  font-family: 'Inter', system-ui, -apple-system, sans-serif;
  font-size: 14px;
  text-align: center;
}

input:disabled, select:disabled {
  color: #bbbbbb;
}

input:not(:disabled), select:not(:disabled) {
  border: 2px solid lightgrey;
  color: #555555;
}

.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  padding: 10px 20px;
  font-size: 0.95rem;
  font-weight: 500;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
  white-space: nowrap;
  user-select: none;
}

.containing-table {
  background: #fafafb;
  display: none;
  margin-left: auto;
  margin-right: auto;
  max-height: 370px;
  width: fit-content;
  padding-left: 5px;
  padding-right: 5px;
  overflow: auto;
  border: 1px solid rgba(255, 255, 255, 0.3);
  text-align: left;
  border-radius: 8px;
  box-shadow:0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  scrollbar-width: 8px;
}

.center {
  width: 100%;
  text-align: center;
}
</style>
</head>
<body>
<span align="center" style="font-size: 24px;"><b>FoxFlake environment selection</b></span>
<div id='title' style="margin-top: 10px; margin-bottom: 10px;">Choose the desktop environment you would like to use:</div>
<div class="containing-table" id="response-container"></div>
<div id='title' style="margin-top: 10px; margin-bottom: 10px;">Select the native NixOS applications you would like to install:</div>
<div class="containing-table" id="response-container2"></div>
<div style="position: fixed; bottom: 10px; left: 10px;"><button style="width:120px" onclick="exit()"><b>Exit</b></button></div>
<div style="position: fixed; bottom: 10px; right: 10px;"><button style="width:120px" onclick="select()"><b>Update</b></button></div> &raquo;</a></div>
<script>
   function showResponse(response) {
        document.getElementById('response-container').innerHTML = response
        document.getElementById('response-container').style.display = 'block'
    }

   function showResponse2(response) {
        document.getElementById('response-container2').innerHTML = response
        document.getElementById('response-container2').style.display = 'block'
    }
    
    function exit() {
        pywebview.api.destroy()
    }

    function select() {
        returnvalue = ""
        const radios = document.querySelectorAll('input[name="radio"]')
        for (const radio of radios) {
            if (radio.checked) {
                returnvalue = radio.value + "^"
                break
            }
        }
        const checkboxes = document.querySelectorAll('input[name="checkbox"]')
        for (const checkbox of checkboxes) {
            if (checkbox.checked) {
                returnvalue = returnvalue + checkbox.value + "^"
            }
        }
        pywebview.api.selected(returnvalue)
    }

    window.addEventListener('pywebviewready', function() {
        pywebview.api.generate_radio().then(showResponse)
        pywebview.api.generate_checkbox().then(showResponse2)
    })
</script>
</body>
</html>
"""

class foxflake:
    def generate_radio(self):
        available_desktops=args.availabledesktops.split('|')
        current_desktop=args.currentdesktop.split('^')
        innerhtml=${"''"}
        for desktops in available_desktops:
            desktop=desktops.split('^')
            if desktop[1] == current_desktop[0]:
                selection=" checked"
            else:
                selection=""
            innerhtml += '<label for="' + desktop[1] + '" class="pure-radio" style="margin-right: 50px;"><input type="radio" id="' + desktop[1] + '" name="radio" value="' + desktop[1] + '"' + selection + '/> ' + desktop[0] + '</label><br>'
        return innerhtml
    def generate_checkbox(self):
        available_applications=args.availableapplications.split('|')
        current_applications=args.currentapplications.split('^')
        innerhtml=${"''"}
        for applications in available_applications:
            application=applications.split('^')
            if application[2] == "":
                innerhtml += '<div style="margin-bottom: 0px; margin-top: 5px;"><span style="margin-left: 0px; width: 300px;"><b>' + application[1] + '</b></span></b></div>'
            else:
                if application[2] in current_applications:
                    selection=" checked"
                else:
                    selection=""
                innerhtml += '<span class="center"><span style="margin-left: 2px; width: 100px;"><label for="' + application[2] + '" class="pure-checkbox"><input type="checkbox" id="' + application[2] + '" name="checkbox" value="' + application[2] + '"' + selection + '/> ' + application[0] + ": " + '</label></span><span style="margin-left: 0px; width: 300px;">' + application[1] + '</span></span><br>'
        return innerhtml
    def selected(self, returnvalue):
        window.destroy()
        print(returnvalue)
        sys.exit()
    def destroy(self):
        window.destroy()
        sys.exit()

if __name__ == '__main__':
    api = foxflake()
    window = webview.create_window('FoxFlake environment selection', html=html, js_api=api, resizable=False, width=800, height=600)
    webview.start(gui='gtk')
FOXFLAKE_GUI

	available_desktops="
Gnome^gnome|\
Plasma^plasma|\
Cosmic^cosmic"

	available_applications="
Internet^Web browsers, email clients and messaging apps^|\
Firefox^An open-source browser managed by Mozilla that prioritizes user privacy^firefox|\
Librewolf^A fork of Firefox that provides the highest level of privacy/security^librewolf|\
Brave^A privacy-focused browser that automatically blocks ads and trackers^brave|\
Chrome^Google’s proprietary web browser known for its speed^chrome|\
Chromium^The open-source version of Google’s Chrome web browser^chromium|\
Thunderbird^Mozilla’s free and open-source email client^thunderbird|\
Evolution^Email client and personal information management tool^evolution|\
Discord^A popular proprietary platform for voice, video, and text communication^discord|\
Office^Office software^|\
LibreOffice^The standard open-source Linux alternative to Microsoft Office^libreoffice|\
OnlyOffice^A sleek office suite focused on high compatibility with Microsoft Office^onlyoffice|\
Document Scanner^A utility providing a simple interface for scanning documents^simple-scan|\
Shutter^A feature-rich Linux screenshot tool with built-in editing and effects^shutter|\
Xournal++^A lightweight tool for taking handwritten notes and annotating PDF files^xournal|\
Multimedia^Multimedia applications^|\
VLC media player^A versatile multimedia that support most audio/video formats^vlc|\
MPV media player^A multimedia player favored for its minimalist interface^mpv|\
Darktable^A photo management application designed to streamline post-production^darktable|\
DigiKam^A photo management application used for organizing and editing photos^digikam|\
Kdenlive^A powerful non-linear video editor built on the KDE framework^kdenlive|\
Shotcut^A non-linear video editor that supports a wide range of formats^shotcut|\
Audacity^A popular multi-track audio editor and recorder^audacity|\
Ardour^A digital audio workstation for recording, editing, mixing, and mastering^ardour|\
NoiseTorch^Real-time microphone noise suppression^noisetorch|\
Development^Software development applications^|\
VS Code^Microsoft’s feature-rich code editor^vscode|\
VS Codium^A telemetry-free version of Microsoft’s feature-rich code editor^vscodium|\
Zed^A high-performance, GPU-accelerated code editor written in Rust^zed|\
Creativity^Content creation software^|\
GIMP^A powerful and open-source image editor^gimp|\
Krita^A digital painting studio designed for concept artists and illustrators^krita|\
Inkscape^A vector graphics editor ideal for creating logos and diagrams^inkscape|\
OBS Studio^The industry standard for screen recording and live streaming^obs|\
Blender^A 3D creation suite that allows modeling, animation and editing^blender|\
Gaming^Gaming applications^|\
Steam^Valve’s industry-leading digital storefront and games launcher^steam|\
Heroic Games Launcher^An open-source launcher for Epic Games, GOG, and Amazon Games^heroic|\
Lutris^A comprehensive launcher for Steam, GOG and Epic games^lutris|\
Faugus^A lightweight game launcher that uses UMU to run Windows games^faugus|\
Gaming Optimizations^FoxFlake optimizations to provide a smooth gaming experience^gaming-optimizations|\
Sunshine^An open-source game streaming host for Moonlight clients^sunshine|\
GOverlay^A GUI that allows you to easily manage and configure overlays^goverlay|\
MangoJuice^A utility designed to help manage MangoHud profiles^mangojuice|\
Input Remapper^A utility for remapping input devices buttons and creating macros^input-remapper|\
Virtualisation^Virtualisation software^|\
WinBoat^Allows to run Windows apps on Linux using a containerized approach^winboat|\
Waydroid^A container-based solution that allows you to run Android apps^waydroid|\
GNOME Boxes^A simple graphical application for creating Virtual Machines^gnome-boxes|\
VirtualBox^A popular hypervisor by Oracle that allows you to run Virtual Machines^virtualbox|\
Virt-Manager^A Virtual Machines manager that provides an interface for QEMU/libvirt^virt-manager|\
Docker^The industry-standard for running applications inside containers^docker|\
Distrobox^A tool that facilitates the use of containers (via Podman or Docker)^distrobox|\
Podman^A powerful, daemonless, and security-focused container engine^podman
Hardware^Hardware Management / Control^|\
OpenRGB^A tool to control RGB lighting across motherboards, RAM, GPUs...^openrgb|\
CoreCtrl^A tool to control hardware performance, fan curves, and power profiles^corectrl"

	set +e
	current_desktop="$(${self.gnugrep}/bin/grep 'foxflake.environment.type' /etc/nixos/configuration.nix | ${self.gnugrep}/bin/grep -v '^[[:space:]]*#' | ${self.coreutils}/bin/tail -1 | ${self.coreutils}/bin/cut -d \" -f 2)"
	set -e

	set +e
	current_applications="^$(${self.gnugrep}/bin/grep 'foxflake.system.bundles' /etc/nixos/configuration.nix | ${self.gnugrep}/bin/grep -v '^[[:space:]]*#' | ${self.coreutils}/bin/tail -1 | ${self.gnugrep}/bin/grep --only-matching '\[.*]' | ${self.gnused}/bin/sed 's@\[\|]@@g' | ${self.gnused}/bin/sed 's@\"[[:space:]]*\"@^@g' | ${self.gnused}/bin/sed 's@\"\| @@g')^"
	if [ "''${current_applications}" == "^^" ]; then
		current_applications="^$(${self.gnugrep}/bin/grep 'foxflake.system.applications' /etc/nixos/configuration.nix | ${self.gnugrep}/bin/grep -v '^[[:space:]]*#' | ${self.coreutils}/bin/tail -1 | ${self.gnugrep}/bin/grep --only-matching '\[.*]' | ${self.gnused}/bin/sed 's@\[\|]@@g' | ${self.gnused}/bin/sed 's@\"[[:space:]]*\"@^@g' | ${self.gnused}/bin/sed 's@\"\| @@g')^"
	fi
	${self.gnugrep}/bin/grep 'foxflake.system.waydroid' /etc/nixos/configuration.nix | ${self.gnugrep}/bin/grep -v '^[[:space:]]*-' | ${self.coreutils}/bin/tail -1 | ${self.gnugrep}/bin/grep -q 'true' && current_applications="''${current_applications}waydroid^"
	current_applications="$(echo "''${current_applications}" | ${self.gnused}/bin/sed 's@\^standard^@^firefox^thunderbird^libreoffice^@g')"
	current_applications="$(echo "''${current_applications}" | ${self.gnused}/bin/sed 's@\^gaming^@^steam^heroic^lutris^@g')"
	current_applications="$(echo "''${current_applications}" | ${self.gnused}/bin/sed 's@\^studio^@^gimp^inkscape^obs^kdenlive^blender^audacity^@g')"
	set -e

	return_value=$(python "''${foxflake_environment_selection_gui}" -aa "''${available_applications}" -ad "''${available_desktops}" -ca "''${current_applications}" -cd "''${current_desktop}")
	if [ -z "''${return_value}" ]; then exit 1; fi

	new_desktop="\"$(echo "''${return_value}" | ${self.coreutils}/bin/cut -d '^' -f 1)\""
	new_applications="[ \"$(echo "''${return_value}" | ${self.coreutils}/bin/cut -d '^' -f 2- | ${self.gnused}/bin/sed 's/.$//' | ${self.gnused}/bin/sed 's@\^@\" \"@g')\" ]"

	exec /run/wrappers/bin/sudo /run/current-system/sw/bin/foxflake-environment-selection "''${new_desktop}" "''${new_applications}"

elif [ ''${#} -eq 2 ] && { [ "''${1}" == "\"cosmic\"" ] || [ "''${1}" == "\"gnome\"" ] || [ "''${1}" == "\"plasma\"" ]; }; then

	if [ "$(${self.coreutils}/bin/id -u)" -ne 0 ]; then
		exec /run/wrappers/bin/sudo /run/current-system/sw/bin/foxflake-environment-selection "''${1}" "''${2}"
	fi

	if ! ${self.curl}/bin/curl --progress-bar --connect-timeout 60 --retry 10 --retry-delay 1 -L -f https://github.com/sebanc/foxflake > /dev/null 2>&1; then
		${self.zenity}/bin/zenity --width=640 --title="FoxFlake environment selection" --error --ok-label="Exit" --text "Error: Please ensure you are connected to the internet before running FoxFlake environment selection."
		exit 1
	fi
	
	current_environment="$(if ${self.gnugrep}/bin/grep -q 'foxflake.environment.type.*;' /etc/nixos/configuration.nix; then ${self.gnugrep}/bin/grep 'foxflake.environment.type.*;' /etc/nixos/configuration.nix | ${self.gnugrep}/bin/grep -o '"[^\"]\+"'; else echo ""; fi)"
	echo "Current environment is ''${current_environment}" > /tmp/${name}.log
	echo -e "New desktop is ''${1}\nNew applications are ''${2}" >> /tmp/${name}.log

	${self.gnused}/bin/sed -i "s@foxflake.system.bundles@foxflake.system.applications@g" /etc/nixos/configuration.nix
	if ${self.gnugrep}/bin/grep -q 'foxflake.environment.type.*;' /etc/nixos/configuration.nix && ${self.gnugrep}/bin/grep -q 'foxflake.system.applications.*;' /etc/nixos/configuration.nix; then
		echo -e "foxflake.environment.type and foxflake.system.applications found in configuration.nix" >> /tmp/${name}.log
		${self.gnused}/bin/sed -i "/foxflake.system.waydroid/d" /etc/nixos/configuration.nix
		${self.gnused}/bin/sed -i "s@foxflake.environment.type.*;@foxflake.environment.type = ''${1};@g" /etc/nixos/configuration.nix
		${self.gnused}/bin/sed -i "s@foxflake.system.applications.*;@foxflake.system.applications = ''${2};@g" /etc/nixos/configuration.nix
	else
		echo -e "foxflake.environment.type and foxflake.system.applications not found in configuration.nix" >> /tmp/${name}.log
		${self.gnused}/bin/sed -i "/foxflake.system.waydroid/d" /etc/nixos/configuration.nix
		${self.gnused}/bin/sed -i "/foxflake.environment.type/d" /etc/nixos/configuration.nix
		${self.gnused}/bin/sed -i "/foxflake.system.applications/d" /etc/nixos/configuration.nix
		${self.gnused}/bin/sed -i "s/^}$/  foxflake.environment.type = ''${1};\n}/g" /etc/nixos/configuration.nix
		${self.gnused}/bin/sed -i "s/^}$/  foxflake.system.applications = ''${2};\n}/g" /etc/nixos/configuration.nix
	fi

	${self.foxflake-update}/bin/foxflake-update 2>&1 | ${self.coreutils}/bin/tee -a /tmp/${name}.log >(while read -r line; do echo "''${line}"; echo "# ''${line}\n\n"; done | /run/wrappers/bin/sudo -u "$(${self.coreutils}/bin/id -nu "''${SUDO_UID}")" ${self.zenity}/bin/zenity --height=240 --width=640 --title="FoxFlake environment selection" --text="Rebuilding system, please wait..." --progress --pulsate --no-cancel --auto-close 2>/dev/null) || { /run/wrappers/bin/sudo -u "$(${self.coreutils}/bin/id -nu "''${SUDO_UID}")" ${self.zenity}/bin/zenity --width=640 --title="FoxFlake environment selection" --error --ok-label="Exit" --text "Error: Failed to rebuild the system.\n\nThe log has been saved in the file \"/tmp/${name}.log\"." 2>/dev/null; exit 1; }

	if [ "''${current_environment}" != "''${1}" ]; then
		echo "Cleaning dconf and GTK settings" >> /tmp/${name}.log
		/run/wrappers/bin/sudo -u "$(${self.coreutils}/bin/id -nu "''${SUDO_UID}")" ${self.dconf}/bin/dconf reset -f /
		for gtkconfig in /home/*/.gtkrc* /home/*/.config/gtkrc* /home/*/.config/gtk-* /home/*/.config/dconf; do ${self.coreutils}/bin/rm -rf "''${gtkconfig}"; done
	fi

	/run/wrappers/bin/sudo -u "$(${self.coreutils}/bin/id -nu "''${SUDO_UID}")" ${self.zenity}/bin/zenity --width=640 --title="FoxFlake environment selection" --info --ok-label="Exit" --text "The system has been updated.\n\nChanges will be applied on next boot." 2>/dev/null

else

	echo "Invalid command line parameters."
	exit 1

fi
            '';
          };
          desktopEntry = self.makeDesktopItem {
            name = name;
            desktopName = "FoxFlake Environment Selection";
            icon = "foxflake-green-icon";
            exec = "/run/current-system/sw/bin/foxflake-environment-selection";
            terminal = false;
            categories = ["Utility"];
          };
        in ''
mkdir -p $out/bin
cp ${script}/bin/${name} $out/bin
mkdir -p $out/share/applications
cp ${desktopEntry}/share/applications/${name}.desktop $out/share/applications/${name}.desktop
        '';
        dontBuild = true;
      };
    })
  ];
}
