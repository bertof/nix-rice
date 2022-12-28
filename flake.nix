{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; inputs.flake-utils.follows = "flake-utils"; };
  };

  outputs = { self, nixpkgs-lib, flake-utils, pre-commit-hooks }: {
    # library
    lib = import ./lib.nix { inherit (nixpkgs-lib) lib; };

    # overlay
    overlays.default = import ./overlay.nix;
  } // flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import pre-commit-hooks.inputs.nixpkgs { inherit system; }; in
    {
      checks = {
        pre-commit-check = pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            deadnix.enable = true;
            nix-linter.enable = true;
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
