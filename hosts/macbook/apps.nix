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
    ../../modules/apps/zsh
    ../../modules/apps/git
    ../../modules/apps/starship
    ../../modules/apps/fastfetch
    ../../modules/apps/zoxide
    ../../modules/apps/fzf
    ../../modules/apps/direnv
    ../../modules/apps/fnm
    # ../../modules/apps/wireguard-mac
  ];

  zsh.enable = true;
  git.enable = true;
  starship.enable = true;
  fastfetch.enable = true;
  zoxide.enable = true;
  fzf.enable = true;
  direnv.enable = true;
  fnm.enable = true;
  # wireguard-mac.enable = true;
}
