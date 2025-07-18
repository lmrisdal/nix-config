{ pkgs, ... }:
{
  gamescope-session = pkgs.callPackage ./gamescope-session.nix { };
  steamos-session-select = pkgs.callPackage ./steamos-session-select.nix { };
  steamos-select-branch = pkgs.callPackage ./steamos-select-branch.nix { };
  jupiter-biosupdate = pkgs.callPackage ./jupiter-biosupdate.nix { };
}
