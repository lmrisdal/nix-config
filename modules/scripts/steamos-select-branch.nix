{ pkgs, ... }:
pkgs.writeShellScriptBin "steamos-select-branch" ''
  #!/bin/bash
  echo "Not applicable for this OS"
''
