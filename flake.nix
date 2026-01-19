{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    kitty-themes-src = { url = "github:kovidgoyal/kitty-themes"; flake = false; };
    systems.url = "github:nix-systems/default";
    flake-parts = { url = "github:hercules-ci/flake-parts"; inputs.nixpkgs-lib.follows = "nixpkgs-lib"; };
    git-hooks-nix = { url = "github:cachix/git-hooks.nix"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } {
    systems = import inputs.systems;
    imports = [ inputs.git-hooks-nix.flakeModule ];
    perSystem = { config, pkgs, ... }: {
      pre-commit.settings.hooks = {
        deadnix.enable = true;
        nixpkgs-fmt.enable = true;
        statix.enable = true;
      };

      devShells.default = pkgs.mkShell {
        inputsFrom = [ config.pre-commit.devShell ];
      };

      formatter = pkgs.nixpkgs-fmt;

      checks.tests =
        let
          inherit (inputs.nixpkgs-lib) lib;
          inherit (inputs) kitty-themes-src;
          nix-rice-lib =
            lib.callPackagesWith { inherit lib kitty-themes-src; } ./lib.nix
              { };
          # Evaluate tests - assertions will fail the build if they don't pass
          testResult = import ./tests/default.nix { inherit nix-rice-lib; };
        in
        pkgs.runCommand "tests" { } ''
          ${lib.deepSeq testResult ""}
          touch $out
        '';
    };

    flake =
      let
        inherit (inputs.nixpkgs-lib) lib;
        inherit (inputs) kitty-themes-src;
        nix-rice = inputs.nixpkgs-lib.lib.callPackagesWith { inherit lib kitty-themes-src; } ./lib.nix { };
      in
      {
        lib = { inherit nix-rice; };

        overlays.default = _self: super: { lib = super.lib // { inherit nix-rice; }; };

        nixosModules.default = { config, lib, pkgs, ... }: {
          options.nix-rice = {
            enable = lib.mkEnableOption "nix-rice, a ricing framework for your system configurations";
            lib = lib.mkOption {
              default = nix-rice;
              defaultText = "lib.nix-rice";
              description = "nix-rice library to be used";
              type = lib.types.attrs;
            };
            config = lib.mkOption {
              description = "Rice configuration for the system";
              type = lib.types.attrs;
              default = rec {
                normal = nix-rice.lib.palette.defaultPalette;
                bright = nix-rice.lib.palette.brighten 10 normal;
                dark = nix-rice.lib.palette.darken 10 normal;
                primary = { background = normal.black; foreground = normal.white; };
                font = {
                  normal = { name = "Cantarell"; package = pkgs.cantarell-fonts; size = 10; };
                  monospace = { name = "CaskaydiaCove Nerd Font"; package = pkgs.nerdfonts.override { fonts = [ "CascadiaCode" ]; }; size = 10; };
                };
                opacity = 0.95;
              };
            };
            rice = lib.mkOption {
              default = config.nix-rice.config;
              description = "Rice configuration (read only)";
              readOnly = true;
            };
          };
        };
      };
  };
}
