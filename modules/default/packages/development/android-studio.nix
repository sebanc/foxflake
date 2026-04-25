{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "android-studio" config.foxflake.system.applications) {

    nixpkgs.config.android_sdk.accept_license = true;
    environment.systemPackages = with pkgs; [ stable.android-studio ];

  };

}
