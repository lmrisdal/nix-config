{ pkgs, ... }:
pkgs.writeShellScriptBin "steamos-session-select" ''
  #!/bin/bash
  steam -shutdown
''
