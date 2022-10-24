{ pkgs ? import <nixos> { inherit system; }, system ? builtins.currentSystem }:
let
  self = with pkgs; {
    lockscreen = callPackage ./lockscreen { };
    sddm-theme-clairvoyance = callPackage ./sddm-theme-clairvoyance { };
  };
in
self
