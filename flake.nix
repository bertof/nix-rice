{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    flake-utils.url = "github:numtide/flake-utils";
    kitty-themes-src = { url = "github:kovidgoyal/kitty-themes"; flake = false; };
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; inputs.flake-utils.follows = "flake-utils"; };
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = { self, nixpkgs-lib, flake-utils, kitty-themes-src, pre-commit-hooks, ... }:
    let
      nix-rice = nixpkgs-lib.lib.callPackagesWith { inherit (nixpkgs-lib) lib; inherit kitty-themes-src; } ./lib.nix { };
    in
    {
      # library
      lib = nix-rice;

      # overlay
      overlays.default = _self: super: { lib = super.lib // { inherit nix-rice; }; };
    } // flake-utils.lib.eachDefaultSystem (system:
      let pkgs = pre-commit-hooks.inputs.nixpkgs.legacyPackages.${system}; in
      {
        default = nix-rice;

        checks = {
          pre-commit-check = pre-commit-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              deadnix.enable = true;
              nixpkgs-fmt.enable = true;
              statix.enable = true;
            };
          };
        };

        devShells.default = pkgs.mkShell {
          shellHook = ''
            ${self.checks.${system}.pre-commit-check.shellHook}            
          '';
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}
