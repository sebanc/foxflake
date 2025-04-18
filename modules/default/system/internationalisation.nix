{ config, lib, pkgs, ... }:
with lib;

{
  options.foxflake.internationalisation = {
    timezone = mkOption {
      type = with types; nullOr str;
      default = null;
      description = "FoxFlake timezone selection";
    };
    defaultLocale = mkOption {
      description = "FoxFlake defaultLocale selection";
      type = with types; str;
      default = "en_US.UTF-8";
    };
    extraLocaleSettings = mkOption {
      description = "FoxFlake extraLocaleSettings selection";
      type = with types; attrsOf str;
      default = { };
    };
    keyboard = {
      consoleKeymap = mkOption {
        type = with types; either str path;
        default = "us";
        description = "FoxFlake console keymap selection";
      };
      layout = mkOption {
        type = with types; str;
        default = "us";
        description = "FoxFlake keyboard layout selection";
      };
      variant = mkOption {
        type = with types; str;
        default = "";
        description = "FoxFlake keyboard variant selection";
      };
    };
  };

  config = {

    time.timeZone = mkDefault config.foxflake.internationalisation.timezone;

    i18n.defaultLocale = mkDefault config.foxflake.internationalisation.defaultLocale;

    i18n.extraLocaleSettings = mkDefault config.foxflake.internationalisation.extraLocaleSettings;

    console.keyMap = mkDefault config.foxflake.internationalisation.keyboard.consoleKeymap;

  };
  
}
