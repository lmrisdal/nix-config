{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    impermanence.url = "github:nix-community/impermanence";
    ucodenix.url = "github:e-tho/ucodenix";
    wayland-pipewire-idle-inhibit = {
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      nixosConfigurations =
        let
          fullname = "Lars Risdal";
          username = "lars";
        in
        {
          nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs outputs;
              inherit fullname username;
              vars = {
                desktop = true;
                gaming = true;
              };
            };
            modules = [
              ./hosts/desktop
              inputs.chaotic.nixosModules.default
              inputs.disko.nixosModules.disko
              ./hosts/desktop/disko.nix
              inputs.nix-flatpak.nixosModules.nix-flatpak
              inputs.ucodenix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  backupFileExtension = "hmbackup";
                  #useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs; # Experiment with config and other attributes
                    inherit fullname username;
                    vars = {
                      desktop = true;
                      gaming = true;
                    };
                  };
                  sharedModules = with inputs; [
                    #catppuccin.homeModules.catppuccin
                    #impermanence.homeManagerModules.impermanence
                    nix-flatpak.homeManagerModules.nix-flatpak
                    #nix-index-database.homeModules.nix-index
                    #nur.modules.homeManager.default
                    #nvf.homeManagerModules.default
                    #plasma-manager.homeManagerModules.plasma-manager
                    #sops-nix.homeManagerModules.sops
                    # wayland-pipewire-idle-inhibit.homeModules.default
                  ];
                };
              }
            ];
          };
        };
    };
}
