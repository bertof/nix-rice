{ lib, kitty-themes-src, ... }:
let
  callPackage = lib.callPackageWith (self // { inherit lib kitty-themes-src; });
  self = {
    op = callPackage ./operators.nix { };
    float = callPackage ./float.nix { };
    hex = callPackage ./hex.nix { };
    color = callPackage ./color.nix { };
    palette = callPackage ./palette.nix { };
    kitty-themes = callPackage ./kitty-themes.nix { };
  };
in
self

