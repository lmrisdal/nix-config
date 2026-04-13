{
  lib,
  pkgs,
  username,
  config,
  inputs,
  ...
}:
{
  imports = [
    ./homebrew.nix
    ../../modules/apps/zsh
    ../../modules/apps/starship
    ../../modules/apps/fastfetch
    ../../modules/apps/zoxide
    ../../modules/apps/fzf
    ../../modules/apps/direnv
    ../../modules/apps/fnm
    ../../modules/apps/ghostty
    ../../modules/apps/azure-artifacts-credprovider
  ];

  brew.enable = true;
  zsh.enable = true;
  starship.enable = true;
  fastfetch.enable = true;
  zoxide.enable = true;
  fzf.enable = true;
  direnv.enable = true;
  fnm.enable = true;
  ghostty.enable = true;
  artifacts-credprovider.enable = true;
}
