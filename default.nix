{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> {}
, lib ? pkgs.lib
, ...
}:
let
  callPackage = lib.callPackageWith (pkgs // self);
  self = rec {
    op = callPackage ./operators {};
    float = callPackage ./float {};
    hex = callPackage ./hex {};
    color = callPackage ./color {};
    palette = callPackage ./palette {};
  };
in
(self)
