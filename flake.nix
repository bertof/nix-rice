{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; inputs.flake-utils.follows = "flake-utils"; };
  };

  outputs = { self, nixpkgs, flake-utils, pre-commit-hooks }: {
    overlays.default = import ./overlay.nix;
  } // flake-utils.lib.eachDefaultSystem (system:
    let pkgs = import nixpkgs { inherit system; }; in
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
