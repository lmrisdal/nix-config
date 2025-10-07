{
  lib,
  config,
  pkgs,
  username,
  vars,
  ...
}:
let
  cfg = config.virtualization;
in
{
  options = {
    virtualization = {
      enable = lib.mkEnableOption "Enable virtualization in NixOS & home-manager";
    };
  };
  config = lib.mkIf cfg.enable {
    boot = {
      extraModprobeConfig = ''
        options kvm_amd nested=1
        options kvm ignore_msrs=1 report_ignored_msrs=0
      '';
    };

    environment = {
      systemPackages = with pkgs; [
        quickemu
        spice
        spice-protocol
        virtiofsd
        virtio-win
        win-spice
      ];
    };
    networking.firewall.trustedInterfaces = [ "virbr0" ];
    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = true;
          ovmf.enable = true;
          ovmf.packages = [ pkgs.OVMFFull.fd ];
          vhostUserPackages = with pkgs; [ virtiofsd ];
        };
      };
      spiceUSBRedirection.enable = true;
      vmVariant = {
        virtualisation = {
          memorySize = 4096;
          cores = 3;
        };
      };
      docker = {
        enable = true;
      };
    };

    programs.virt-manager.enable = true;
    users.groups.libvirtd.members = [ "${username}" ];
    users = {
      users = {
        ${username} = {
          extraGroups = [
            "docker"
            "kvm"
            "libvirtd"
          ];
        };
      };
    };

    home-manager.users.${username} =
      { pkgs, config, ... }:
      {
        dconf.enable = true;
        dconf.settings = {
          "org/virt-manager/virt-manager/connections" = {
            autoconnect = [ "qemu:///system" ];
            uris = [ "qemu:///system" ];
          };
        };
      };
  };
}
