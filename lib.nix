{ lib, ... }:
let
  self = {
    op = lib.callPackageWith self ./operators.nix { inherit lib; };
    float = lib.callPackageWith self ./float.nix { inherit lib; };
    hex = lib.callPackageWith self ./hex.nix { inherit lib; };
    color = lib.callPackageWith self ./color.nix { inherit lib; };
    palette = lib.callPackageWith self ./palette.nix { inherit lib; };
  };
in
self

