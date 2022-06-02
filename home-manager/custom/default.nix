{ pkgs ? import <nixpkgs> { inherit system; }
, system ? builtins.currentSystem
}:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);
  self = {
    lockscreen = callPackage ./lockscreen { };
  };
in
(self)
