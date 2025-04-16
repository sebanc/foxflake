{
  lib,
  config,
  options,
  pkgs,
  ...
}:
with lib;

let
  DISTRO_NAME = "FoxFlake";
  DISTRO_ID = "foxflake";

  needsEscaping = s: null != builtins.match "[a-zA-Z0-9]+" s;
  escapeIfNeccessary = s: if needsEscaping s then s else ''"${escape [ "\$" "\"" "\\" "\`" ] s}"'';
  attrsToText =
    attrs:
    concatStringsSep "\n" (mapAttrsToList (n: v: ''${n}=${escapeIfNeccessary (toString v)}'') attrs)
    + "\n";
  osReleaseContents = {
    NAME = DISTRO_NAME;
    ID = DISTRO_ID;
    VERSION = "${config.system.nixos.release} (${config.system.nixos.codeName})";
    VERSION_CODENAME = toLower config.system.nixos.codeName;
    VERSION_ID = config.system.nixos.release;
    BUILD_ID = config.system.nixos.version;
    PRETTY_NAME = "${DISTRO_NAME} ${config.system.nixos.release} (${config.system.nixos.codeName})";
    LOGO = "";
    HOME_URL = "";
    DOCUMENTATION_URL = "";
    SUPPORT_URL = "";
    BUG_REPORT_URL = "";
  };
  initrdReleaseContents = osReleaseContents // {
    PRETTY_NAME = "${osReleaseContents.PRETTY_NAME} (Initrd)";
  };
  initrdRelease = pkgs.writeText "initrd-release" (attrsToText initrdReleaseContents);
in
{
  options.foxflake.stateVersion = mkOption {
    description = "Initially installed FoxFlake version.";
    type = types.str;
    default = config.system.nixos.release;
  };

  config = {
    environment.etc."os-release".text = mkForce (attrsToText osReleaseContents);
    environment.etc."lsb-release".text = mkForce (attrsToText {
      LSB_VERSION = "${config.system.nixos.release} (${config.system.nixos.codeName})";
      DISTRIB_ID = DISTRO_ID;
      DISTRIB_RELEASE = config.system.nixos.release;
      DISTRIB_CODENAME = toLower config.system.nixos.codeName;
      DISTRIB_DESCRIPTION = "${DISTRO_NAME} ${config.system.nixos.release} (${config.system.nixos.codeName})";
    });
    boot.initrd.systemd.contents."/etc/os-release".source = mkForce initrdRelease;
    boot.initrd.systemd.contents."/etc/initrd-release".source = mkForce initrdRelease;
    system.nixos.distroName = DISTRO_NAME;
    system.nixos.distroId = DISTRO_ID;
    system.stateVersion = mkDefault config.foxflake.stateVersion;
  };
}
