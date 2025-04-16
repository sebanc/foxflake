{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

let
  foxflake-icons = pkgs.callPackage ../../../packages/foxflake-icons {};
in
{

  options.foxflake.customization = {
    enable = mkOption {
      description = "Enable FoxFlake design customizations";
      type = types.bool;
      default = if (config.foxflake.environment.enable) then
        true
      else
        false;
    };
    wallpaper = mkOption {
      type = with types; str;
      default = "${pkgs.nixos-artwork.wallpapers.simple-blue.gnomeFilePath}";
      example = "/etc/wallpapers/mywallpaper.png";
      description = ''
        The wallpaper to use by default for , ensure that is
        sourced in a folder within /etc directory.
      '';
    };
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
  };

  config = mkIf config.foxflake.customization.enable {

    boot.loader.grub = {
      splashImage =
        if config.foxflake.customization.grub.theme != null then
          null
        else
          mkDefault config.foxflake.customization.grub.splashImage;
      theme = mkDefault config.foxflake.customization.grub.theme;
    };

    environment.systemPackages = with pkgs; [ foxflake-icons (sleek-grub-theme.override { withBanner = "FoxFlake"; withStyle = "light"; }) ];
  };

}
