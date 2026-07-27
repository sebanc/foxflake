{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (config.foxflake.environment.enable && config.foxflake.environment.type == "hyprland") {

    nixpkgs.config.packageOverrides = pkgs: {
      catppuccin-sddm-corners = pkgs.catppuccin-sddm-corners.overrideAttrs (oldAttrs: {
        postInstall = (oldAttrs.postInstall or "") + ''
          if [ -f "$out/share/sddm/themes/catppuccin-sddm-corners/theme.conf" ]; then
            sed -i 's@Background="backgrounds/flatppuccin_macchiato.png"@Background="${config.foxflake.customization.environment.wallpaper}"@g' "$out/share/sddm/themes/catppuccin-sddm-corners/theme.conf"
            sed -i 's@GeneralFontSize="9"@GeneralFontSize="14"@g' "$out/share/sddm/themes/catppuccin-sddm-corners/theme.conf"
          fi
        '';
      });
    };

    environment = {
      pathsToLink = [
        "/share/backgrounds"
        "/share/icons"
        "/share/wlogout"
      ];
      sessionVariables = {
        NIXOS_OZONE_WL = mkDefault "1";
        ELECTRON_OZONE_PLATFORM_HINT = mkDefault "wayland";
      };
      systemPackages = with pkgs; [
        adwaita-icon-theme
        bazaar
        blueman
        brightnessctl
        catppuccin-sddm-corners
        grim
        hyprlock
        hyprpaper
        kitty
        mako
        nemo-with-extensions
        networkmanagerapplet
        nwg-dock-hyprland
        nwg-drawer
        pavucontrol
        tela-circle-icon-theme
        waybar
        wireplumber
        wl-clipboard
        wlogout
      ];
    };

    fonts.packages = with pkgs; [
      nerd-fonts.noto
    ];

    programs = {
      bash.promptInit = mkDefault ''
        PS1="\n\[\033[1;36m\][\[\e]0;\u@\h: \w\a\]\u@\h:\w]\$\[\033[0m\] "
      '';
      dconf = {
        enable = mkDefault true;
        profiles.user.databases = mkDefault [
          {
            settings = {
              "org/gnome/desktop/interface" = {
                cursor-theme = "${config.foxflake.customization.environment.cursor-theme}";
                gtk-theme = "${config.foxflake.customization.environment.theme}";
                icon-theme = "${config.foxflake.customization.environment.icon-theme}";
                font-name = "Noto Sans Medium 11";
                document-font-name = "Noto Sans Medium 11";
                monospace-font-name = "Noto Sans Mono Medium 11";
              };
              "org/gnome/desktop/peripherals/touchpad" = {
                click-method = "areas";
                tap-to-click = true;
                two-finger-scrolling-enabled = true;
              };
              "org/gnome/nm-applet" = {
                disable-connected-notifications = true;
                disable-disconnected-notifications = true;
              };
            };
          }
        ];
      };
      hyprland = {
        enable = mkDefault true;
        xwayland.enable = mkDefault true;
      };
      hyprlock.enable = mkDefault true;
      iio-hyprland.enable = mkDefault true;
    };

    security.pam.services.hyprlock = {};

    services = {
      displayManager = {
        sddm = {
          enable = mkDefault true;
          autoNumlock = mkDefault true;
          settings.Theme = {
            CursorTheme = mkDefault "${config.foxflake.customization.environment.cursor-theme}";
            CursorSize = mkDefault "24";
          };
          theme = mkDefault "catppuccin-sddm-corners";
          wayland = {
            enable = mkDefault true;
            compositor = mkDefault "kwin";
          };
          extraPackages = with pkgs; [ kdePackages.qt5compat ];
        };
        defaultSession = mkDefault "hyprland";
      };
      hypridle.enable = mkDefault true;
    };

    systemd.user.services = {
      hyprland-defaults = {
        description = "Apply hyprland global defaults";
        unitConfig.DefaultDependencies = false;
        wantedBy = [ "basic.target" ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.writeShellScriptBin "hyprland-defaults" ''
            #!${pkgs.bash}

            if [ ! -d "''${HOME}/.config/hypr" ]; then
              mkdir -p "''${HOME}/.config/hypr"
              cat >"''${HOME}/.config/hypr/hyprland.lua" <<'HYPRLAND_CONFIG_LUA'
            local monitor_defined = false
            local real_hl_monitor = hl.monitor
            hl.monitor = function(opts)
              monitor_defined = true
              return real_hl_monitor(opts)
            end
            hl.on("hyprland.start", function()
              if not monitor_defined then
                for _, monitor in ipairs(hl.get_monitors()) do
                  local scale = monitor.height > 1600 and 2 or 1
                  print(string.format("Setting %s (Height: %d) to scale %d", monitor.name, monitor.height, scale))
                  hl.monitor({
                    output   = monitor.name,
                    mode     = "preferred",
                    position = "auto",
                    scale    = scale,
                  })
                end
              end
              hl.exec_cmd("xdg-user-dirs-gtk-update")
              hl.exec_cmd("hyprctl setcursor ${config.foxflake.customization.environment.cursor-theme} 24")
              hl.exec_cmd("hypridle")
              hl.exec_cmd("hyprpaper")
              hl.exec_cmd("waybar")
              hl.exec_cmd("nwg-dock-hyprland -x -p \"bottom\" -lp start -ico start-here -c \"nwg-drawer --nocats --nofs -c 5 -mb 10 -mt 10 -ml 10 -mr 10\" -i 48 -mt 10 -mb 10 -ml 10 -mr 10")
              hl.exec_cmd("mako")
              hl.exec_cmd("blueman-applet")
              hl.exec_cmd("nm-applet --indicator")
            end)
            hl.config({
              general = {
                gaps_in = 6,
                gaps_out = 12,
                border_size = 2,
                col = {
                  active_border = { colors = {"rgba(ffffffff)", "rgba(3d3d3dff)"}, angle = 45 },
                  inactive_border = "rgba(595959aa)",
                },
              },
              decoration = {
                rounding = 12,
                active_opacity = 1.0,
                inactive_opacity = 0.92,
                dim_inactive = true,
                dim_strength = 0.15,
                shadow = {
                  enabled = true,
                  range = 8,
                  render_power = 3,
                  color = "rgba(000000ee)",
                },
                blur = {
                  enabled = true,
                  size = 6,
                  passes = 2,
                  new_optimizations = true,
                },
              },
              cursor = {
                no_hardware_cursors = true,
              },
              input = {
                kb_layout = "${config.foxflake.internationalisation.keyboard.layout}",
                kb_variant = "${config.foxflake.internationalisation.keyboard.variant}",
                numlock_by_default = true,
                repeat_rate = 50,
                repeat_delay = 300,
              },
            })
            hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
            hl.bind("SUPER + T", hl.dsp.exec_cmd("kitty"))
            hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("[float] kitty"))
            hl.bind("SUPER + SHIFT + T", hl.dsp.exec_cmd("[float] kitty"))
            hl.bind("SUPER + code:10", hl.dsp.focus({ workspace = 1 }))
            hl.bind("SUPER + code:11", hl.dsp.focus({ workspace = 2 }))
            hl.bind("SUPER + code:12", hl.dsp.focus({ workspace = 3 }))
            hl.bind("SUPER + code:13", hl.dsp.focus({ workspace = 4 }))
            hl.bind("SUPER + SHIFT + code:10", hl.dsp.window.move({ workspace = 1 }))
            hl.bind("SUPER + SHIFT + code:11", hl.dsp.window.move({ workspace = 2 }))
            hl.bind("SUPER + SHIFT + code:12", hl.dsp.window.move({ workspace = 3 }))
            hl.bind("SUPER + SHIFT + code:13", hl.dsp.window.move({ workspace = 4 }))
            hl.bind("ALT + Tab", hl.dsp.window.cycle_next(""))
            hl.bind("ALT + Tab", hl.dsp.window.bring_to_top())
            hl.bind("ALT + SHIFT + Tab", hl.dsp.window.cycle_next("prev"))
            hl.bind("ALT + SHIFT + Tab", hl.dsp.window.bring_to_top())
            hl.bind("SUPER + Q", hl.dsp.window.close())
            hl.bind("SUPER + F", hl.dsp.window.fullscreen(0))
            hl.bind("SUPER + M", hl.dsp.window.fullscreen(1))
            hl.bind("SUPER + P", hl.dsp.window.pseudo())
            hl.bind("SUPER + D", hl.dsp.exec_cmd("pkill nwg-drawer || nwg-drawer --nocats --nofs -c 5 -mb 10 -mt 10 -ml 10 -mr 10"))
            hl.bind("SUPER + E", hl.dsp.exec_cmd("nemo --no-desktop"))
            hl.bind("SUPER + X", hl.dsp.exec_cmd("pkill wlogout || wlogout -p layer-shell -b 5 -L 300 -R 300 -T 300 -B 300"))
            hl.bind("SUPER + SHIFT + SPACE", hl.dsp.window.float({ action = "toggle" }))
            hl.bind("SUPER + mouse:273", hl.dsp.window.resize())
            hl.bind("SUPER + mouse:272", hl.dsp.window.drag())
            hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
            hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
            hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
            hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
            hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
            hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
            hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
            hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
            hl.bind("SUPER + L", hl.dsp.exec_cmd("loginctl lock-session"))
            hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { repeating = true })
            hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { repeating = true })
            hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
            hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +10%"))
            hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 10%-"))
            hl.bind("Print", hl.dsp.exec_cmd("grim - | wl-copy"))
            hl.window_rule({
              name = "zenity",
              match = {
                class = "^(zenity)$",
              },
              center = true,
              float = true,
              stay_focused = true,
            })
            HYPRLAND_CONFIG_LUA
              cat >"''${HOME}/.config/hypr/hypridle.conf" <<'HYPRIDLE_CONFIG'
            general {
              lock_cmd = pidof hyprlock || hyprlock
              before_sleep_cmd = loginctl lock-session
            }
            listener {
              timeout = 300
              on-timeout = brightnessctl set 10%
              on-resume = brightnessctl set 100%
            }
            listener {
              timeout = 600
              on-timeout = loginctl lock-session
            }
            listener {
              timeout = 1800
              on-timeout = systemctl suspend
            }
            HYPRIDLE_CONFIG
              cat >"''${HOME}/.config/hypr/hyprlock.conf" <<'HYPRLOCK_CONFIG'
            general {
              immediate_render = true
              ignore_empty_input = false
            }
            background {
              monitor =
              path = ${config.foxflake.customization.environment.wallpaper}
              blur_passes = 2
              blur_size = 6
            }
            input-field {
              monitor =
              size = 300, 60
              outline_thickness = 4
              dots_size = 0.3
              dots_spacing = 0.2
              dots_center = true
              fade_on_empty = false
              outer_color = rgba(0, 0, 0, 0.1)
              inner_color = rgba(255, 255, 255, 0.1)
              font_color = rgb(255, 255, 255)
              font_family = Noto Sans
              placeholder_text = Input Password...
              fail_color = rgba(255, 0, 0, 0.8)
              check_color = rgba(0, 255, 0, 0.8)
              position = 0, -20
              halign = center
              valign = center
              rounding = -1
            }
            label {
              monitor =
              text = cmd[update:1000] date +"%A, %d %B %Y - %H:%M"
              font_color = rgb(255, 255, 255)
              font_family = Noto Sans
              font_size = 28
              position = 0, 200
              halign = center
              valign = center
            }
            HYPRLOCK_CONFIG
              cat >"''${HOME}/.config/hypr/hyprpaper.conf" <<'HYPRPAPER_CONFIG'
            wallpaper {
              monitor = 
              path = ${config.foxflake.customization.environment.wallpaper}
              fit_mode = cover
            }
            splash = false
            ipc = off
            HYPRPAPER_CONFIG
              mkdir -p "''${HOME}/.config/kitty"
              cat >"''${HOME}/.config/kitty/kitty.conf" <<'KITTY_CONFIG'
            background_opacity 0.8
            blur_background true
            blur_background_size 10
            foreground #ffffff
            background #121212
            selection_foreground #ffffff
            selection_background #3d3d3d
            cursor #ffffff
            cursor_text_color #121212
            url_color #0087bd
            confirm_os_window_close 0
            KITTY_CONFIG
              mkdir -p "''${HOME}/.config/mako"
              cat >"''${HOME}/.config/mako/config" <<'MAKO_CONFIG'
            # Global Settings
            max-history=5
            sort=-time
            # Appearance
            font=Noto 11
            width=350
            height=150
            margin=20,20
            padding=15
            border-size=2
            border-radius=15
            icons=1
            max-icon-size=64
            # Colors
            background-color=#282a36e6
            text-color=#ffffff
            border-color=#89b4fa
            progress-color=over #313244
            # Layout
            icon-location=left
            history=1
            text-alignment=left
            # Interaction
            default-timeout=5000
            ignore-timeout=1
            [urgency=high]
            border-color=#f38ba8
            default-timeout=0
            MAKO_CONFIG
              mkdir -p "''${HOME}/.config/nwg-dock-hyprland"
              cat >"''${HOME}/.config/nwg-dock-hyprland/style.css" <<'NWG_DOCK_CSS'
            window {
              background-color: rgba(0, 0, 0, 0);
            }
            #box {
              animation: fadeIn 0.4s ease-out;
              background-color: rgba(0, 0, 0, 0);
              border: none;
              padding: 0;
              margin: 0;
              box-shadow: none;
            }
            button {
              background: none;
              border: none;
              outline: none; 
              box-shadow: none;
              margin-left: 5px;
              margin-right: 5px;
              padding: 0;
            }
            button:hover {
              background-color: rgba(255, 255, 255, 0.1);
              border-radius: 12px;
            }
            button#active {
              background-color: rgba(255, 255, 255, 0.05);
              border-radius: 12px;
              background: none;
              border: none;
              box-shadow: none;
            }
            tooltip {
              background-color: transparent;
              border: none;
            }
            tooltip label {
              background-color: rgba(40, 40, 40, 0.9);
              color: #ffffff;
              border-radius: 12px;
              margin-top: 5px;
              padding: 10px 10px;
            }
            NWG_DOCK_CSS
              mkdir -p "''${HOME}/.cache"
              cat >"''${HOME}/.cache/nwg-dock-pinned" <<'NWG_DOCK_PINNED'
            nemo
            kitty
            io.github.kolunmi.Bazaar
            NWG_DOCK_PINNED
              chmod 0755 "''${HOME}/.cache/nwg-dock-pinned"
              mkdir -p "''${HOME}/.config/nwg-drawer"
              cat >"''${HOME}/.config/nwg-drawer/drawer.css" <<'NWG_DRAWER_CSS'
            window {
              background-color: rgba(40, 42, 54, 0.9);
              border-radius: 15px;
              color: #ffffff;
            }
            button {
              background: rgba(40, 42, 54, 0.0);
              font-family: "Noto", sans-serif;
              color: #ffffff;
              border: none;
              box-shadow: none;
              margin: 5px;
              padding: 10px;
            }
            button:hover {
              background-color: rgba(255, 255, 255, 0.1);
              border-radius: 12px;
              box-shadow: 0 4px 15px rgba(0, 0, 0, 0.3);
              transition: all 0.2s ease;
            }
            NWG_DRAWER_CSS
              mkdir -p "''${HOME}/.config/waybar"
              cat >"''${HOME}/.config/waybar/config" <<'WAYBAR_CONFIG'
            {
              "layer": "top",
              "position": "top",
              "height": 40,
              "spacing": 10,
              "margin-top": 10,
              "margin-left": 10,
              "margin-right": 10,
              "modules-left": [
                "hyprland/workspaces",
                "cpu",
                "memory"
              ],
              "modules-center": [
                "clock"
              ],
              "modules-right": [
                "tray",
                "pulseaudio",
                "battery",
                "custom/power"
              ],
              "hyprland/workspaces": {
                "format": "{icon}",
                "on-click": "activate",
                "persistent-workspaces": {
                  "*": 4
                },
                "tooltip": false
              },
              "cpu": {
                "interval": 2,
                "format": " {usage}%",
                "tooltip": false
              },
              "memory": {
                "interval": 10,
                "format": " {used:0.1f}G",
                "tooltip": false
              },
              "clock": {
                "format": "{:%A, %d %B %Y - %H:%M}",
                "tooltip": false
              },
              "tray": {
                "icon-size": 16,
                "spacing": 5,
                "tooltip": false
              },
              "pulseaudio": {
                "format": "{icon} {volume}%",
                "format-muted": "󰝟 Muted",
                "format-icons": {
                  "headphone": "",
                  "hands-free": "",
                  "headset": "",
                  "phone": "",
                  "portable": "",
                  "car": "",
                  "default": ["", "", ""]
                },
                "on-click": "pavucontrol",
                "scroll-step": 5,
                "tooltip": false
              },
              "battery": {
                "states": { "critical": 15 },
                "format": "{icon} {capacity}%",
                "format-icons": ["", "", "", "", ""],
                "tooltip": false
              },
              "custom/power": {
                "format": "⏻",
                "on-click": "wlogout -p layer-shell -b 5 -L 300 -R 300 -T 300 -B 300",
                "tooltip": false
              }
            }
            WAYBAR_CONFIG
              cat >"''${HOME}/.config/waybar/style.css" <<'WAYBAR_CSS'
            * {
              font-family: "Noto", sans-serif;
              font-size: 13px;
              border: none;
              box-shadow: none;
              background-color: transparent;
              border-radius: 0;
            }
            window#waybar {
              background-color: rgba(26, 27, 38, 0);
              color: #ffffff;
              transition-property: background-color;
              transition-duration: .5s;
            }
            tooltip {
              background-color: transparent;
              border-radius: 12px;
            }
            tooltip label {
              background-color: rgba(40, 40, 40, 0.9);
              color: #ffffff;
              border-radius: 12px;
              margin-top: 5px;
              padding: 10px 10px;
            }
            menu {
              background: none;
              padding-top: 40px;
            }
            menuitem {
              color: #ffffff;
              min-height: 30px;
              padding: 0px;
            }
            menuitem:hover {
              color: #89b4fa;
            }
            menuitem,
            #workspaces,
            #cpu,
            #memory,
            #clock,
            #tray,
            #pulseaudio,
            #battery,
            #custom-power {
              background-color: rgba(40, 42, 54, 0.8);
              padding: 0px 15px;
              margin: 5px 3px;
              border-radius: 15px;
              border: 1px solid rgba(255, 255, 255, 0.1);
            }
            #workspaces button {
              padding: 0 5px;
              color: #888888;
            }
            #workspaces button.active {
              color: #ffffff;
            }
            #workspaces button:hover {
              background: none;
              color: #89b4fa;
            }
            #workspaces button.urgent {
              color: #ff5555;
            }
            #battery.charging {
              color: #50fa7b;
            }
            #battery.critical:not(.charging) {
              background-color: #ff5555;
              color: #ffffff;
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: linear;
              animation-iteration-count: infinite;
              animation-direction: alternate;
            }
            WAYBAR_CSS
              mkdir -p "''${HOME}/.config/wlogout"
              cat >"''${HOME}/.config/wlogout/layout" <<'WLOGOUT_CONFIG'
            {
              "label" : "lock",
              "action" : "hyprlock",
              "keybind" : "l"
            },
            {
              "label" : "logout",
              "action" : "hyprctl dispatch exit 0",
              "keybind" : "e"
            },
            {
              "label" : "suspend",
              "action" : "hyprlock & systemctl suspend",
              "keybind" : "u"
            },
            {
              "label" : "reboot",
              "action" : "systemctl reboot",
              "keybind" : "r"
            },
            {
              "label" : "shutdown",
              "action" : "systemctl poweroff",
              "keybind" : "s"
            }
            WLOGOUT_CONFIG
              cat >"''${HOME}/.config/wlogout/style.css" <<'WLOGOUT_CSS'
            window {
              background-color: rgba(15, 15, 15, 0.8);
            }
            button {
              color: #ffffff;
              background-color: rgba(45, 45, 45, 0.5);
              border: 2px solid rgba(255, 255, 255, 0.1);
              border-radius: 20px;
              margin: 100px 25px;
              min-height: 100px;
              min-width: 100px;
              background-repeat: no-repeat;
              background-position: center;
              background-size: 50%;
              transition: all 0.3s ease-in-out;
            }
            button:focus,
            button:active,
            button:hover {
              background-color: rgba(100, 100, 100, 0.3);
              border: 2px solid #89b4fa;
              outline-style: none;
            }
            #lock {
              background-image: image(url("/run/current-system/sw/share/wlogout/icons/lock.png"));
            }
            #logout {
              background-image: image(url("/run/current-system/sw/share/wlogout/icons/logout.png"));
            }
            #suspend {
              background-image: image(url("/run/current-system/sw/share/wlogout/icons/suspend.png"));
            }
            #reboot {
              background-image: image(url("/run/current-system/sw/share/wlogout/icons/reboot.png"));
            }
            #shutdown {
              background-image: image(url("/run/current-system/sw/share/wlogout/icons/shutdown.png"));
            }
            WLOGOUT_CSS
            fi
          ''}/bin/hyprland-defaults";
        };
        restartIfChanged = false;
      };
    };

    xdg.portal = {
      enable = mkDefault true;
      extraPortals = mkDefault [ pkgs.xdg-desktop-portal-hyprland ];
      xdgOpenUsePortal = mkDefault true;
    };

  };

}
