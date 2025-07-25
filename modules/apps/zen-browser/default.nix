{
  lib,
  config,
  username,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.zen-browser;
in
{
  options = {
    zen-browser = {
      enable = lib.mkEnableOption "Enable zen in NixOS";
    };
  };
  config = lib.mkIf cfg.enable {
    home-manager.users.${username} =
      { config, pkgs, ... }:
      {
        imports = [
          inputs.zen-browser.homeModules.beta
        ];
        programs.zen-browser = {
          enable = true;
          nativeMessagingHosts = [ pkgs.firefoxpwa ];
          policies = {
            AutofillAddressEnabled = true;
            AutofillCreditCardEnabled = false;
            DisableAppUpdate = true;
            DisableFeedbackCommands = true;
            DisableFirefoxStudies = true;
            DisablePocket = true; # save webs for later reading
            DisableTelemetry = true;
            DontCheckDefaultBrowser = true;
            NoDefaultBookmarks = true;
            OfferToSaveLogins = false;
            EnableTrackingProtection = {
              Value = true;
              Locked = true;
              Cryptomining = true;
              Fingerprinting = true;
            };
            ExtensionSettings = {
              "uBlock0@raymondhill.net" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
                installation_mode = "force_installed";
              };
              "{d634138d-c276-4fc8-924b-40a0ea21d284}" = {
                install_url = "https://addons.mozilla.org/firefox/downloads/latest/1password-x-password-manager/latest.xpi";
                installation_mode = "force_installed";
              };
            };
            Preferences =
              let
                locked = value: {
                  "Value" = value;
                  "Status" = "locked";
                };
              in
              {
                "browser.tabs.warnOnClose" = locked false;
              };
          };
        };
      };
  };
}
