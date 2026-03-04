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
        default = "${pkgs.minimal-grub-theme}";
        example = literalExpression ''"''${pkgs.libsForQt5.breeze-grub}/grub/themes/breeze"'';
        description = ''
          Path to the grub theme to be used.
        '';
      };
    };
    environment = {
      wallpaper = mkOption {
        type = with types; nullOr str;
        default = if config.foxflake.environment.type == "plasma" then
          "/run/current-system/sw/share/wallpapers/foxflake-neon-wallpaper/contents/images/3840x2160.png"
        else
          "/run/current-system/sw/share/backgrounds/foxflake/foxflake-neon-wallpaper.png";
        example = "/home/common/wallpaper.png";
        description = ''
          The wallpaper used by default for the display manager and desktop environment.
        '';
      };
      theme = mkOption {
        type = with types; nullOr str;
        default = if config.foxflake.environment.type == "gnome" then
          "Adwaita"
        else if config.foxflake.environment.type == "plasma" then
          "default"
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
        default = "Adwaita";
        example = "Breeze_Light";
        description = ''
          The cursor theme to use.
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

  };

}
