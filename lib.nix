{ lib, ... }:
let
  callPackage = lib.callPackageWith (self // { inherit lib; });
  self = {
    op = callPackage ./operators.nix { };
    float = callPackage ./float.nix { };
    hex = callPackage ./hex.nix { };
    color = callPackage ./color.nix { };
    palette = callPackage ./palette.nix { };
  };
in
self

