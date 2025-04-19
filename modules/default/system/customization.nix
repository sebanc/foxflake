{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.customization = {
    grub = {
      splashImage = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = literalExpression "./my-background.png";
        description = ''
          Background image used for GRUB.
          Set to `null` to run GRUB in text mode.

          ::: {.note}
          File must be one of .png, .tga, .jpg, or .jpeg. JPEG images must
          not be progressive.
          The image will be scaled if necessary to fit the screen.
          :::
        '';
      };
      theme = mkOption {
        type = with types; nullOr path;
        default = "${pkgs.sleek-grub-theme}";
        example = literalExpression ''"''${pkgs.libsForQt5.breeze-grub}/grub/themes/breeze"'';
        description = ''
          Path to the grub theme to be used.
        '';
      };
    };
    environment = {
      wallpaper = mkOption {
        type = with types; nullOr str;
        default = "${pkgs.nixos-artwork.wallpapers.simple-blue.gnomeFilePath}";
        example = "/etc/wallpapers/mywallpaper.png";
        description = ''
          The wallpaper to use by default, ensure that is
          sourced in a folder within /etc directory.
        '';
      };
      theme = mkOption {
        type = with types; nullOr str;
        default = if config.foxflake.environment.type == "gnome" then
          "Adwaita"
        else
          null;
        example = "Adwaita";
        description = ''
          The windows decorations theme to use.
        '';
      };
      icon-theme = mkOption {
        type = with types; nullOr str;
        default = "Tela-circle";
        example = "Adwaita";
        description = ''
          The icon theme to use.
        '';
      };
      cursor-theme = mkOption {
        type = with types; nullOr str;
        default = if config.foxflake.environment.type == "gnome" then
          "Adwaita"
        else
          "Breeze_Light";
        example = "Adwaita";
        description = ''
          The cursor theme to use.
        '';
      };
      launcher-icon = mkOption {
        type = with types; nullOr str;
        default = "nix-snowflake-white";
        example = "icon-name";
        description = ''
          The icon to use for the application launcher.
        '';
      };
    };
  };

  config = {

    boot.loader.grub = {
      splashImage =
        if config.foxflake.customization.grub.theme != null then
          null
        else
          mkDefault config.foxflake.customization.grub.splashImage;
      theme = mkDefault config.foxflake.customization.grub.theme;
    };

    foxflake.customization.grub.theme = mkDefault (pkgs.sleek-grub-theme.override { withBanner = "OS Selection"; withStyle = "light"; });
    environment.systemPackages = [ (pkgs.callPackage ../../../packages/foxflake-icons {}) ];

  };

}
