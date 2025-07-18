{ pkgs, ... }:
{
  services.gnome.gnome-initial-setup.enable = false;
  # services.gnome.games.enable = true;
  environment.gnome.excludePackages = with pkgs.gnome; [
    #gnome-backgrounds
    #pkgs.gnome-video-effects
    pkgs.gnome-maps
    pkgs.gnome-music
    pkgs.gnome-tour
    pkgs.gnome-text-editor
    pkgs.gnome-user-docs
    pkgs.gnome-connections
    pkgs.gnome-weather
    pkgs.simple-scan
    pkgs.totem
    pkgs.epiphany
    pkgs.geary
    pkgs.evince
  ];
  environment.systemPackages = with pkgs; [
    gnomeExtensions.blur-my-shell
    gnomeExtensions.compact-top-bar
    gnomeExtensions.custom-accent-colors
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tray-icons-reloaded
    pkgs.gnome-tweaks
    gnomeExtensions.arcmenu
    gnomeExtensions.just-perfection
    gnomeExtensions.vitals
  ];
}
