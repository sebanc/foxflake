{
  lib,
  config,
  pkgs,
  ...
}:
with lib;

{

  config = mkIf (builtins.elem "full" config.foxflake.system.applications || builtins.elem "vscode" config.foxflake.system.applications) {

    environment.systemPackages = [
      (pkgs.stable.vscode.overrideAttrs (oldAttrs: {
        postPatch = builtins.replaceStrings [ "resources/app/node_modules/@vscode/ripgrep/bin/rg" ] [ "resources/app/node_modules/@vscode/ripgrep-universal/bin/linux-x64/rg" ] oldAttrs.postPatch;
      }))
    ];

  };

}
