{
  description = "Minimal flake environment";

  inputs = {
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    flake-utils.url = "github:numtide/flake-utils";
    kitty-themes = { url = "github:kovidgoyal/kitty-themes"; flake = false; };
    pre-commit-hooks = { url = "github:cachix/pre-commit-hooks.nix"; inputs.flake-utils.follows = "flake-utils"; };
  };

  outputs = { self, nixpkgs-lib, flake-utils, kitty-themes, pre-commit-hooks }: {
    # library
    lib = nixpkgs-lib.lib.callPackagesWith { inherit (nixpkgs-lib) lib; inherit kitty-themes; } ./lib.nix { };

    # overlay
    overlays.default = import ./overlay.nix;
  } // flake-utils.lib.eachDefaultSystem (system:
    let pkgs = pre-commit-hooks.inputs.nixpkgs.legacyPackages.${system}; in
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
