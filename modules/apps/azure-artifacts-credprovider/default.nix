{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  cfg = config.artifacts-credprovider;
in
{
  options = {
    artifacts-credprovider = {
      enable = lib.mkEnableOption "Enable Azure Artifacts Credential Provider";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { lib, config, ... }:
      {
        home.file."artifacts-credprovider" = {
          target = ".nuget/plugins/netcore/CredentialProvider.Microsoft/";
          recursive = true;
          source = pkgs.fetchzip rec {
            name = "artifacts-credprovider";

            version = "1.4.1";
            hash = "sha256-37h+G1v8FHOpzDftL8OLYrfPWcu45Es5dMG2eLaKg8k=";

            url = "https://github.com/microsoft/artifacts-credprovider/releases/download/v${version}/Microsoft.NuGet.CredentialProvider.tar.gz";
            stripRoot = false;
            postFetch = ''
              shopt -s extglob
              rm -rv $out/!(plugins)
              mv $out/plugins/netcore/CredentialProvider.Microsoft/* $out
              rm -rv $out/plugins
            '';
          };
        };
      };
    #environment.systemPackages = [ artifacts-credprovider ];
  };
}
