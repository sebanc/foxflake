{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  options.foxflake.networking = {
    hostname = mkOption {
      description = ''
        The name of the machine. Leave it empty if you want to obtain it from a
        DHCP server (if using DHCP). The hostname must be a valid DNS label (see
        RFC 1035 section 2.3.1: "Preferred name syntax", RFC 1123 section 2.1:
        "Host Names and Numbers") and as such must not contain the domain part.
        This means that the hostname must start with a letter or digit,
        end with a letter or digit, and have as interior characters only
        letters, digits, and hyphen. The maximum length is 63 characters.
        Additionally it is recommended to only use lower-case characters.
        If (e.g. for legacy reasons) a FQDN is required as the Linux kernel
        network node hostname (uname --nodename) the option
        boot.kernel.sysctl."kernel.hostname" can be used as a workaround (but
        the 64 character limit still applies).

        WARNING: Do not use underscores (_) or you may run into unexpected issues.
      '';
      type = types.strMatching "^$|^[[:alnum:]]([[:alnum:]_-]{0,61}[[:alnum:]])?$";
      default = config.system.nixos.distroId;
    };
  };

  config = {

    networking.hostName = mkDefault config.foxflake.networking.hostname;

  };

}
