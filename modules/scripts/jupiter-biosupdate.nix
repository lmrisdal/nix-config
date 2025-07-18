{ pkgs, ... }:
pkgs.writeShellScriptBin "jupiter-biosupdate" ''
  #!/bin/bash
  exit 0;
''
