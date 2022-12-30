{ pkgs ? import <nixpkgs> { } }: pkgs.lib.callPackageWith pkgs ./lib.nix
