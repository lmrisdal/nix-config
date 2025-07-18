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
    nix-proton-cachyos.url = "github:jbgi/nix-proton-cachyos";
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Theming
    catppuccin = {
      url = "github:catppuccin/nix";
    };
    catppuccin-ghostwriter = {
      url = "github:catppuccin/ghostwriter";
      flake = false;
    };
    catppuccin-halloy = {
      url = "github:catppuccin/halloy";
      flake = false;
    };
    catppuccin-heroic = {
      url = "github:catppuccin/heroic";
      flake = false;
    };
    catppuccin-konsole = {
      url = "github:catppuccin/konsole";
      flake = false;
    };
    catppuccin-obs = {
      url = "github:catppuccin/obs";
      flake = false;
    };
    catppuccin-powershell = {
      url = "github:catppuccin/powershell";
      flake = false;
    };
    catppuccin-xresources = {
      url = "github:catppuccin/xresources";
      flake = false;
    };
    catppuccin-zen = {
      url = "github:IAmJafeth/zen-browser";
      flake = false;
    };
    lightly.url = "github:Bali10050/Darkly";

    # KDE
    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kwin-effects-kinetic = {
      url = "github:gurrgur/kwin-effects-kinetic";
      flake = false;
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
              inputs.catppuccin.nixosModules.catppuccin
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
                    inherit fullname username;
                    vars = {
                      desktop = true;
                      gaming = true;
                    };
                  };
                  sharedModules = with inputs; [
                    catppuccin.homeModules.catppuccin
                    impermanence.homeManagerModules.impermanence
                    nix-flatpak.homeManagerModules.nix-flatpak
                    #nix-index-database.homeModules.nix-index
                    nur.modules.homeManager.default
                    #nvf.homeManagerModules.default
                    #plasma-manager.homeManagerModules.plasma-manager
                    #sops-nix.homeManagerModules.sops
                    wayland-pipewire-idle-inhibit.homeModules.default
                  ];
                };
              }
            ];
          };
        };
    };
}
