# {
#   config,
#   lib,
#   pkgs,
#   ...
# }:

# let
#   cfg = config.wireguard-mac;
#   version = "1.0.16"; # Update this as needed
#   version_underscored = lib.replaceStrings [ "." ] [ "_" ] version;
#   wireguard-mac = pkgs.stdenv.mkDerivation {
#     pname = "wireguard-mac";
#     inherit version;

#     src = pkgs.fetchurl {
#       url = "https://github.com/zakosaba/wireguard-macos-app/releases/download/v${version}/wireguard_${version_underscored}.zip";
#       sha256 = "sha256-34Tqt9W5kRZNUIwaTIWW1Cikz2ogzCAXFq3Azw9r7XU=";
#     };

#     nativeBuildInputs = [
#       pkgs.unzip
#     ];
#     # Disable unnecessary phases
#     dontPatch = true;
#     dontConfigure = true;
#     dontBuild = true;
#     #dontUnpack = true; # We will handle unpacking manually

#     # Extract to current directory
#     sourceRoot = ".";

#     installPhase = ''
#       runHook preInstall

#       mkdir -p $out/Applications

#       # cp -R Wireguard.app $out/Applications

#       # Unzip the downloaded file
#       #unzip -q wireguard_${version_underscored}.zip -d $out/Applications

#       runHook postInstall
#     '';
#   };
# in
# {
#   options = {
#     wireguard-mac = {
#       enable = lib.mkEnableOption "Enable Wireguard (macOS) application";
#     };
#   };

#   config = lib.mkIf cfg.enable {
#     # Add the app to system packages
#     environment.systemPackages = [ wireguard-mac ];

#     # Direct installation method for /Applications
#     system.activationScripts.postActivation.text = lib.mkAfter ''
#       # Install Wireguard to system /Applications
#       app_src="${wireguard-mac}/Applications/Wireguard.app"
#       app_dst="/Applications/Wireguard.app"

#       # Only create install if the source app exists
#       if [ -d "$app_src" ]; then
#         echo "Installing Wireguard.app to /Applications/"

#         # Make a direct copy
#         sudo rm -rf "$app_dst"
#         sudo cp -R "$app_src" "$app_dst"

#         # Set appropriate timestamps to avoid "unknown date" warning
#         NOW=$(date)
#         sudo touch -d "$NOW" "$app_dst"

#         # Remove quarantine attribute if present
#         sudo xattr -rd com.apple.quarantine "$app_dst" 2>/dev/null || true

#         # Fix permissions
#         sudo chown -R root:wheel "$app_dst"

#         # Try to register with Launch Services to refresh app info
#         /System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -f "$app_dst"

#         echo "Wireguard.app installed - You may need to right-click > Open the first time"
#       else
#         echo "Warning: Wireguard.app not found at $app_src"
#       fi
#     '';
#   };
# }
