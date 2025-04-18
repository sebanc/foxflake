{
  config,
  lib,
  pkgs,
  ...
}:
with lib;

let
  userOpts = {
    options.flatpaks = mkOption {
      type = types.listOf types.str;
      default = [ ];
      example = literalExpression "[ { appId = \"org.mozilla.firefox\"; origin = \"flathub\"; } ]";
      description = ''
        The set of packages that should be installed as flatpak.
      '';
    };
  };

  foxflakeuserOpts =
    { name, config, ... }:
    {
      options = {
        name = mkOption {
          type = types.passwdEntry types.str;
          apply =
            x:
            assert (
              stringLength x < 32 || abort "Username '${x}' is longer than 31 characters which is not allowed!"
            );
            x;
          description = ''
            The name of the user account. If undefined, the name of the
            attribute set will be used.
          '';
        };
        description = mkOption {
          type = types.passwdEntry types.str;
          default = "";
          example = "Alice Q. User";
          description = ''
            A short description of the user account, typically the
            user's full name.  This is actually the “GECOS” or “comment”
            field in {file}`/etc/passwd`.
          '';
        };
        isNormalUser = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Indicates whether this is an account for a “real” user.
            This automatically sets {option}`group` to `users`,
            {option}`createHome` to `true`,
            {option}`home` to {file}`/home/«username»`,
            {option}`useDefaultShell` to `true`,
            and {option}`isSystemUser` to `false`.
            Exactly one of `isNormalUser` and `isSystemUser` must be true.
          '';
        };
        extraGroups = mkOption {
          type = types.listOf types.str;
          default = [ ];
          description = "The user's auxiliary groups.";
        };
        packages = mkOption {
          type = types.listOf types.package;
          default = with pkgs; [ ];
          example = literalExpression "with pkgs; [ firefox ]";
          description = ''
            The set of packages that should be made available to the user.
            This is in contrast to {option}`environment.systemPackages`,
            which adds packages to all users.
          '';
        };
        flatpaks = mkOption {
          type = types.listOf types.str;
          default = [ ];
          example = literalExpression "[ { appId = \"org.mozilla.firefox\"; origin = \"flathub\"; } ]";
          description = ''
            The set of packages that should be installed as flatpak.
          '';
        };
      };
      config = mkMerge [
        {
          name = mkDefault name;
        }
      ];
    };
    mkHome = username: {
      "${username}" =  {
        imports = [
          (import ../../home/flatpak.nix { user = "${username}"; })
        ];
        home.stateVersion = mkDefault config.foxflake.stateVersion;
      };
    };
    homeConfigurations = foldr (a: b: a // b) { } (map mkHome (attrNames config.foxflake.users));
in
{
  options = {

    users.users = lib.mkOption {
      type = with lib.types; attrsOf (submodule userOpts);
    };

    foxflake.users = mkOption {
      type = with types; attrsOf (submodule foxflakeuserOpts);
      default = { };
      example = {
        alice = {
          description = "Alice Q. User";
          extraGroups = [ "wheel" ];
          packages = "with pkgs; [ firefox ]";
          flatpaks = "[ { appId = \"org.mozilla.firefox\"; origin = \"flathub\"; } ]";
        };
      };
      description = ''
        Additional user accounts to be created automatically by the system.
        This can also be used to set options for root.
      '';
    };

  };

  config = {

    users.users = config.foxflake.users;
    home-manager.users = homeConfigurations;

  };

}
