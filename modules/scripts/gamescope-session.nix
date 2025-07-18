{ pkgs, ... }:
pkgs.writeShellScriptBin "gamescope-session" ''
  #!/bin/bash
  gamescope -r 120 --mangoapp -e -- steam -steamdeck -steamos3
''
