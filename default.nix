{ pkgs }:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);
  self = rec {
    op = callPackage ./operators.nix { };
    float = callPackage ./float.nix { };
    hex = callPackage ./hex.nix { };
    color = callPackage ./color.nix { };
    palette = callPackage ./palette.nix { };
  };
in
self
