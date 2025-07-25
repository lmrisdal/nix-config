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
    just-one-more-repo = {
      url = "github:ProverbialPennance/just-one-more-repo";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-citizen = {
      url = "github:LovingMelody/nix-citizen";
      inputs.nix-gaming.follows = "nix-gaming";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    wayland-pipewire-idle-inhibit = {
      url = "github:rafaelrc7/wayland-pipewire-idle-inhibit";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-gaming.url = "github:fufexan/nix-gaming";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    cd-ls = {
      url = "github:zshzoo/cd-ls";
      flake = false;
    };
    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };
  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      darwin,
      nix-homebrew,
      ...
    }@inputs:
    let
      inherit (self) outputs;
    in
    {
      darwinConfigurations =
        let
          fullname = "Lars Risdal";
          username = "lars";
        in
        {
          apollo = darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = {
              inherit
                inputs
                outputs
                fullname
                username
                ;
            };
            modules = [
              ./hosts/macbook
              nix-homebrew.darwinModules.nix-homebrew
              {
                nix-homebrew = {
                  # Install Homebrew under the default prefix
                  enable = true;
                  # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
                  enableRosetta = true;
                  # User owning the Homebrew prefix
                  user = "${username}";
                  # Automatically migrate existing Homebrew installations
                  autoMigrate = true;
                };
              }
              home-manager.darwinModules.home-manager
              {
                home-manager = {
                  backupFileExtension = "hmbackup";
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit
                      inputs
                      username
                      fullname
                      ;
                  };
                };
              }
            ];
          };
        };
      nixosConfigurations =
        let
          fullname = "Lars Risdal";
          username = "lars";
          defaultSession = "gnome"; # plasma
        in
        {
          nixos = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs outputs;
              inherit
                fullname
                username
                defaultSession
                ;
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
              inputs.just-one-more-repo.nixosModules.default
              inputs.nix-flatpak.nixosModules.nix-flatpak
              inputs.nur.modules.nixos.default
              inputs.impermanence.nixosModules.impermanence
              inputs.ucodenix.nixosModules.default
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  backupFileExtension = "hmbackup";
                  #useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs; # Experiment with config and other attributes
                    inherit
                      fullname
                      username
                      defaultSession
                      ;
                    vars = {
                      desktop = true;
                      gaming = true;
                    };
                  };
                  sharedModules = with inputs; [
                    impermanence.homeManagerModules.impermanence
                    nix-flatpak.homeManagerModules.nix-flatpak
                    nur.modules.homeManager.default
                    wayland-pipewire-idle-inhibit.homeModules.default
                  ];
                };
              }
            ];
          };
        };
    };
}
