{ pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      foxflake-environment-selection = self.stdenv.mkDerivation rec {
        name = "foxflake-environment-selection";
        buildCommand = let
          script = self.writeShellApplication {
            name = name;
            runtimeInputs = with self; [
              (unstable.python3.withPackages (module: [ module.pyside6 ]))
            ];
            bashOptions = [ "errexit" "pipefail" ];
            excludeShellChecks = [ "SC2028" ];
            text = ''
set -e

unset QT_QPA_PLATFORM_PLUGIN_PATH
unset QT_PLUGIN_PATH
export LD_LIBRARY_PATH=/run/current-system/sw/share/nix-ld/lib

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
import subprocess
import sys
from PySide6.QtCore import Qt, QObject, QTimer, Slot
from PySide6.QtGui import QPalette, QColor
from PySide6.QtWidgets import QApplication, QMainWindow
from PySide6.QtWebEngineWidgets import QWebEngineView
from PySide6.QtWebChannel import QWebChannel
from PySide6.QtWebEngineCore import QWebEnginePage, QWebEngineProfile, QWebEngineSettings

class Bridge(QObject):
    @Slot(str)
    def update(self, message):
        window.destroy()
        print(f"{message}")
        sys.exit()
    @Slot(None)
    def exit(self):
        window.destroy()
        sys.exit()

class MainWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("FoxFlake environment selection")
        self.setFixedSize(800, 600)
        self.web_view = QWebEngineView()
        self.profile = QWebEngineProfile.defaultProfile()
        self.profile_settings = self.profile.settings()
        self.profile_settings.setAttribute(QWebEngineSettings.WebAttribute.WebGLEnabled, False)
        self.profile_settings.setAttribute(QWebEngineSettings.WebAttribute.Accelerated2dCanvasEnabled, False)
        self.profile_settings.setAttribute(QWebEngineSettings.WebAttribute.LocalStorageEnabled, False)
        self.web_page = QWebEnginePage(self.profile, self.web_view)
        self.web_view.setPage(self.web_page)
        self.channel = QWebChannel(self.web_page)
        self.bridge = Bridge(self)
        self.channel.registerObject("backend", self.bridge)
        self.web_page.setWebChannel(self.channel)

        parser = argparse.ArgumentParser()
        parser.add_argument('-aa', '--availableapplications', required=True, help="List of available Applications")
        parser.add_argument('-ad', '--availabledesktops', required=True, help="List of available Desktop Environments")
        parser.add_argument('-ca', '--currentapplications', required=True, help="Currently installed Applications")
        parser.add_argument('-cd', '--currentdesktop', required=True, help="Currently installed Desktop Environment")
        args = parser.parse_args()

        available_desktops=args.availabledesktops.split('|')
        current_desktop=args.currentdesktop.split('^')
        html_desktop = ""
        for desktops in available_desktops:
            desktop=desktops.split('^')
            if desktop[1] == current_desktop[0]:
                selection=" checked"
            else:
                selection=""
            html_desktop += '<label for="' + desktop[1] + '" style="margin-right: 5px;"><input type="radio" id="' + desktop[1] + '" name="radio" value="' + desktop[1] + '"' + selection + '/> ' + desktop[0] + '</label><br>'

        available_applications=args.availableapplications.split('|')
        current_applications=args.currentapplications.split('^')
        html_applications=""
        for applications in available_applications:
            application=applications.split('^')
            if application[2] == "":
                html_applications += '<div style="margin-bottom: 0px; margin-top: 5px;"><span style="margin-left: 0px; width: 300px;"><b>' + application[1] + '</b></span></b></div>'
            else:
                if application[2] in current_applications:
                    selection=" checked"
                else:
                    selection=""
                html_applications += '<span class="center"><span style="margin-left: 2px; width: 100px;"><label for="' + application[2] + '"><input type="checkbox" id="' + application[2] + '" name="checkbox" value="' + application[2] + '"' + selection + '/> ' + application[0] + ": " + '</label></span><span style="margin-left: 0px; width: 300px;">' + application[1] + '</span></span><br>'

        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <style>
                body {{
                    background: {background_color};
                    color: {font_color};
                    font-family: sans-serif;
                }}
                .card {{
                    margin-left: auto;
                    margin-right: auto;
                    height: auto;
                    max-height: 350px;
                    overflow: auto;
                    width: fit-content;
                    background: {card_color};
                    padding: 10px;
                    border-radius: 12px;
                    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
                    scrollbar-width: 8px;
                }}
                .center {{
                    width: 100%;
                    text-align: center;
                    margin-bottom: 5px;
                }}
                button {{
                    background: {button_action_color};
                    color: white; border: none;
                    padding: 7px;
                    border-radius: 5px;
                    cursor: pointer;
                    width: 120px;
                }}
                button:hover {{
                    background: {button_hover_color};
                }}
                input[type="radio"], input[type="checkbox"] {{
                    accent-color: {button_action_color};
                }}
            </style>
            <script src="qrc:///qtwebchannel/qwebchannel.js"></script>
            <script>
                var backend;
                new QWebChannel(qt.webChannelTransport, function (channel) {{
                    backend = channel.objects.backend;
                }});
                function exit() {{
                    if (backend) {{
                        backend.exit()
                    }}
                }}
                function update() {{
                    if (backend) {{
                        returnvalue = ""
                        const radios = document.querySelectorAll('input[name="radio"]')
                        for (const radio of radios) {{
                            if (radio.checked) {{
                                returnvalue = radio.value + "^"
                                break
                            }}
                        }}
                        const checkboxes = document.querySelectorAll('input[name="checkbox"]')
                        for (const checkbox of checkboxes) {{
                            if (checkbox.checked) {{
                                returnvalue = returnvalue + checkbox.value + "^"
                            }}
                        }}
                        backend.update(returnvalue)
                    }}
                }}
            </script>
        </head>
        <body>
            <div class="center">Choose the desktop environment you would like to use:</div>
            <div class="card">
        """
        html_content += html_desktop
        html_content += """
            </div>
            <br>
            <div class="center">Select the native NixOS applications you would like to install:</div>
            <div class="card">
        """
        html_content += html_applications
        html_content += """
            </div>
            <div style="position: fixed; bottom: 15px; left: 15px;"><button onclick="exit()"><b>Exit</b></button></div>
            <div style="position: fixed; bottom: 15px; right: 15px;"><button onclick="update()"><b>Update</b></button></div>
        </body>
        </html>
        """

        self.web_view.setHtml(html_content)
        self.setCentralWidget(self.web_view)

def apply_dark_theme(app):
    app.setStyle("Fusion")
    palette = QPalette()
    palette.setColor(QPalette.Window, QColor(53, 53, 53))
    palette.setColor(QPalette.WindowText, Qt.white)
    palette.setColor(QPalette.Base, QColor(25, 25, 25))
    palette.setColor(QPalette.AlternateBase, QColor(53, 53, 53))
    palette.setColor(QPalette.ToolTipBase, Qt.white)
    palette.setColor(QPalette.ToolTipText, Qt.white)
    palette.setColor(QPalette.Text, Qt.white)
    palette.setColor(QPalette.Button, QColor(53, 53, 53))
    palette.setColor(QPalette.ButtonText, Qt.white)
    palette.setColor(QPalette.BrightText, Qt.red)
    palette.setColor(QPalette.Link, QColor(42, 130, 218))
    palette.setColor(QPalette.Highlight, QColor(42, 130, 218))
    palette.setColor(QPalette.HighlightedText, Qt.black)
    app.setPalette(palette)
    global background_color
    global card_color
    global font_color
    global button_action_color
    global button_hover_color
    background_color = "#141618"
    card_color = "#202326"
    font_color = "#E1E1E1"
    button_action_color = "#3DAEE9"
    button_hover_color = "#1D99F3"

def apply_light_theme(app):
    app.setStyle("Fusion")
    app.setPalette(QApplication.style().standardPalette())
    global background_color
    global card_color
    global font_color
    global button_action_color
    global button_hover_color
    background_color = "#EFF0F1"
    card_color = "#FFFFFF"
    font_color = "#232629"
    button_action_color = "#3DAEE9"
    button_hover_color = "#1D99F3"

def is_cosmic_dark_mode():
    if "cosmic" in os.environ.get("XDG_CURRENT_DESKTOP", "").lower():
        path = os.path.expanduser("~/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark")
        try:
            with open(path, "r") as f:
                return f.read().strip().lower() == "true"
        except FileNotFoundError:
            return False
    else:
        return False

def is_gnome_dark_mode():
    if "gnome" in os.environ.get("XDG_CURRENT_DESKTOP", "").lower():
        try:
            result = subprocess.run(
                ["${self.glib}/bin/gsettings", "get", "org.gnome.desktop.interface", "color-scheme"],
                capture_output=True, text=True
            )
            return "dark" in result.stdout.lower()
        except Exception:
            return False
    else:
        return False

def is_plasma_dark_mode():
    if "kde" in os.environ.get("XDG_CURRENT_DESKTOP", "").lower() or "plasma" in os.environ.get("XDG_CURRENT_DESKTOP", "").lower():
        scheme = app.styleHints().colorScheme()
        return scheme == Qt.ColorScheme.Dark
    else:
        return False

if __name__ == "__main__":
    if "gnome" in os.environ.get("XDG_CURRENT_DESKTOP", "").lower():
        os.environ["QT_QPA_PLATFORM"] = "xcb"
    app = QApplication(sys.argv)
    if is_cosmic_dark_mode() or is_gnome_dark_mode() or is_plasma_dark_mode():
        apply_dark_theme(app)
    else:
        apply_light_theme(app)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
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
Zoom^Video conferencing tool for meetings, webinars, and online collaboration^zoom|\
Slack^Collaborative team messaging platform with channels and app integrations^slack|\
Telegram^Fast, secure cloud-based instant messaging app with heavy encryption^telegram|\
Element^Secure, decentralized messenger and team collaboration client for Matrix^element|\
Office^Office software^|\
LibreOffice^The standard open-source Linux alternative to Microsoft Office^libreoffice|\
OnlyOffice^A sleek office suite focused on high compatibility with Microsoft Office^onlyoffice|\
FocusWriter^Distraction-free writing environment with a hideable interface^focuswriter|\
Document Scanner^A utility providing a simple interface for scanning documents^simple-scan|\
Shutter^A feature-rich Linux screenshot tool with built-in editing and effects^shutter|\
Xournal++^A lightweight tool for taking handwritten notes and annotating PDF files^xournal|\
Calibre^A powerful all-in-one e-book manager for library organization and conversion^calibre|\
Multimedia^Multimedia applications^|\
VLC media player^A versatile multimedia that support most audio/video formats^vlc|\
MPV media player^A multimedia player favored for its minimalist interface^mpv|\
Kodi^Open-source media center for playing videos, music, and digital media^kodi|\
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
Sublime^Sophisticated, lightweight text editor for code, markup, and prose^sublime|\
Zed^A high-performance, GPU-accelerated code editor written in Rust^zed|\
Neovim^Text editor engineered for extensibility and usability^neovim|\
GitKraken^Visual interface for managing Git repositories and code history^gitkraken|\
GitHub Desktop^GUI for managing Git and GitHub^github|\
Creativity^Content creation software^|\
GIMP^A powerful and open-source image editor^gimp|\
Krita^A digital painting studio designed for concept artists and illustrators^krita|\
Inkscape^A vector graphics editor ideal for creating logos and diagrams^inkscape|\
OBS Studio^The industry standard for screen recording and live streaming^obs|\
Blender^A 3D creation suite that allows modeling, animation and editing^blender|\
Reaper^Complete digital audio production application^reaper|\
Gaming^Gaming applications^|\
Steam^Valve’s industry-leading digital storefront and games launcher^steam|\
Heroic Games Launcher^An open-source launcher for Epic Games, GOG, and Amazon Games^heroic|\
Lutris^A comprehensive launcher for Steam, GOG and Epic games^lutris|\
Faugus^A lightweight game launcher that uses UMU to run Windows games^faugus|\
Sunshine^An open-source game streaming host for Moonlight clients^sunshine|\
GOverlay^A GUI that allows you to easily manage and configure overlays^goverlay|\
MangoJuice^A utility designed to help manage MangoHud profiles^mangojuice|\
Piper^An application to configure gaming mice^piper|\
Input Remapper^A utility for remapping input devices buttons and creating macros^input-remapper|\
Joystickwake^A tool that prevents suspend when using a game controller^joystickwake|\
Oversteer^Control utility for steering wheels^oversteer|\
Virtualisation^Virtualisation software^|\
WinBoat^Allows to run Windows apps on Linux using a containerized approach^winboat|\
Bottles^Easily run Windows software on Linux using sandboxed environments^bottles|\
Waydroid^A container-based solution that allows you to run Android apps^waydroid|\
GNOME Boxes^A simple graphical application for creating Virtual Machines^gnome-boxes|\
VirtualBox^A popular hypervisor by Oracle that allows you to run Virtual Machines^virtualbox|\
Virt-Manager^A Virtual Machines manager that provides an interface for QEMU/libvirt^virt-manager|\
Docker^The industry-standard for running applications inside containers^docker|\
Distrobox^A tool that facilitates the use of containers (via Podman or Docker)^distrobox|\
Podman^A powerful, daemonless, and security-focused container engine^podman|\
Utilities^System utilities^|\
GParted^Graphical utility for disk partitioning and file system management^gparted|\
Bitwarden^Cloud-synced, open-source password management^bitwarden|\
KeePassXC^Graphical utility for disk partitioning and file system management^keepassxc|\
Remmina^Versatile client for RDP, VNC, and SSH connections^remmina|\
RustDesk^Open-source, self-hosted remote desktop software^rustdesk|\
AnyDesk^Proprietary, high-speed remote desktop sharing^anydesk|\
TeamViewer^Industry-standard tool for remote support and collaboration^teamviewer|\
Wireshark^Network analysis tool for capturing and inspecting data packets^wireshark|\
Hardware^Hardware management^|\
OpenTabletDriver^Open source and cross-platform tablet driver^opentabletdriver|\
CoreCtrl^A tool to control hardware performance, fan curves, and power profiles^corectrl|\
OpenRGB^A tool to control RGB lighting across motherboards, RAM, GPUs...^openrgb|\
XONE^Xbox One and Xbox Series X/S gamepad driver^xone|\
XPAD neo^Linux driver for Xbox One wireless controllers^xpadneo|\
Fanatec FF^Linux driver for Fanatec driving wheels^fanatecff|\
Logitech FF^Linux driver for Logitech driving wheels^logitechff|\
Gutenprint^A collection of free-software printer drivers^gutenprint|\
Brother LPD^Drivers supporting certain Brother Laser printers^brlaser|\
Brother GenML1^Proprietary drivers supporting more Brother printers^brgenml1|\
Canon CUPS^Printer drivers for Canon Pixma devices^cnijfilter2|\
Epson IPD^Printer drivers for Epson devices^escpr|\
HP LIP^Print, scan and fax HP drivers for Linux^hplip|\
Lexmark CUPS^Printer drivers for Lexmark devices^lexmarkps|\
Samsung ULD^Proprietary drivers for Samsung printers^samsunguld|\
Samsung PL^Drivers for printers supporting SPL Samsung Printer Language^samsungpl"

	set +e
	current_desktop="$(${self.gnugrep}/bin/grep 'foxflake.environment.type' /etc/nixos/configuration.nix | ${self.gnugrep}/bin/grep -v '^[[:space:]]*#' | ${self.coreutils}/bin/tail -1 | ${self.coreutils}/bin/cut -d '#' -f 1 | ${self.coreutils}/bin/cut -d \" -f 2)"
	set -e

	set +e
	current_applications="^$(${self.gnugrep}/bin/grep 'foxflake.system.bundles' /etc/nixos/configuration.nix | ${self.gnugrep}/bin/grep -v '^[[:space:]]*#' | ${self.coreutils}/bin/tail -1 | ${self.coreutils}/bin/cut -d '#' -f 1 | ${self.gnugrep}/bin/grep --only-matching '\[.*]' | ${self.gnused}/bin/sed 's@\[\|]@@g' | ${self.gnused}/bin/sed 's@\"[[:space:]]*\"@^@g' | ${self.gnused}/bin/sed 's@\"\| @@g')^"
	if [ "''${current_applications}" == "^^" ]; then
		current_applications="^$(${self.gnugrep}/bin/grep 'foxflake.system.applications' /etc/nixos/configuration.nix | ${self.gnugrep}/bin/grep -v '^[[:space:]]*#' | ${self.coreutils}/bin/tail -1 | ${self.coreutils}/bin/cut -d '#' -f 1 | ${self.gnugrep}/bin/grep --only-matching '\[.*]' | ${self.gnused}/bin/sed 's@\[\|]@@g' | ${self.gnused}/bin/sed 's@\"[[:space:]]*\"@^@g' | ${self.gnused}/bin/sed 's@\"\| @@g')^"
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
