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
      ];
      sessionVariables = {
        NIXOS_OZONE_WL = mkDefault "1";
        ELECTRON_OZONE_PLATFORM_HINT = mkDefault "wayland";
      };
      systemPackages = with pkgs; [
        adwaita-icon-theme
        bazaar
        brightnessctl
        catppuccin-sddm-corners
        kitty
        nemo-with-extensions
        unstable.noctalia
        wl-clipboard
        (pkgs.unstable.tela-circle-icon-theme.overrideAttrs (oldAttrs: {
          dontCheckForBrokenSymlinks = true;
        }))
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
            };
          }
        ];
      };
      hyprland = {
        enable = mkDefault true;
        xwayland.enable = mkDefault true;
      };
      iio-hyprland.enable = mkDefault true;
    };

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
              hl.exec_cmd("noctalia")
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
            local ipc = "noctalia msg "
            hl.workspace_rule({ workspace = "1", persistent = true })
            hl.workspace_rule({ workspace = "2", persistent = true })
            hl.workspace_rule({ workspace = "3", persistent = true })
            hl.workspace_rule({ workspace = "4", persistent = true })
            hl.layer_rule({
              name = "noctalia",
              match = {
                namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
              },
              no_anim = true,
              ignore_alpha = 0.5,
              blur = true,
              blur_popups = true,
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
            hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold"))
            hl.bind("SUPER + Q", hl.dsp.window.close())
            hl.bind("SUPER + F", hl.dsp.window.fullscreen(0))
            hl.bind("SUPER + M", hl.dsp.window.fullscreen(1))
            hl.bind("SUPER + P", hl.dsp.window.pseudo())
            hl.bind("SUPER + D", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
            hl.bind("SUPER + S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
            hl.bind("SUPER + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
            hl.bind("SUPER + E", hl.dsp.exec_cmd("nemo --no-desktop"))
            hl.bind("SUPER + X", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))
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
            hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), { repeating = true })
            hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), { repeating = true })
            hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"))
            hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(ipc .. "brightness-up"))
            hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(ipc .. "brightness-down"))
            hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
            hl.window_rule({
              name = "zenity",
              match = {
                class = "^(zenity)$",
              },
              center = true,
              float = true,
              stay_focused = true,
            })
            hl.window_rule({
              name = "noctalia-settings",
              match = {
                class = "dev.noctalia.Noctalia",
              },
              float = true,
              size = { 1080, 920 },
            })
            HYPRLAND_CONFIG_LUA
              mkdir -p "''${HOME}/.config/noctalia"
              cat >"''${HOME}/.config/noctalia/config.toml" <<'NOCTALIA_CONFIG'
            [theme]
            mode = "dark"
            source = "builtin"
            builtin = "Catppuccin"

            [wallpaper]
            enabled = true
            default.path = "${config.foxflake.customization.environment.wallpaper}"

            [shell.screenshot]
            save_to_file = false
            copy_to_clipboard = true

            [bar.default]
            position = "top"
            thickness = 40
            background_opacity = 0.0
            shadow = false
            margin_edge = 10
            margin_ends = 10
            capsule = true
            capsule_opacity = 0.8
            capsule_border = "outline"
            capsule_border_width = 1.0
            start = ["workspaces", "cpu", "ram"]
            center = ["clock"]
            end = ["tray", "network", "bluetooth", "volume", "battery", "control-center", "session"]

            [widget.clock]
            format = "{:%A, %d %B %Y - %H:%M}"

            [widget.cpu]
            type = "sysmon"
            stat = "cpu_usage"
            visualization = "none"

            [widget.ram]
            type = "sysmon"
            stat = "ram_used"
            visualization = "none"

            [dock]
            enabled = true
            position = "bottom"
            icon_size = 48
            margin_edge = 10
            launcher_position = "start"
            pinned = ["nemo", "kitty", "io.github.kolunmi.Bazaar"]

            [idle]
            behavior_order = ["dim", "lock", "suspend"]

            [idle.behavior.dim]
            timeout = 300
            action = "command"
            command = "brightnessctl set 10%"
            resume_command = "brightnessctl set 100%"

            [idle.behavior.lock]
            timeout = 600
            action = "lock"

            [idle.behavior.suspend]
            timeout = 1800
            action = "suspend"
            NOCTALIA_CONFIG
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
