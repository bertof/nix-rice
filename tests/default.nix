# Run all tests
{ nix-rice-lib }:
let
  opTests = import ./op.nix { inherit nix-rice-lib; };
  floatTests = import ./float.nix { inherit nix-rice-lib; };
  hexTests = import ./hex.nix { inherit nix-rice-lib; };
  colorTests = import ./color.nix { inherit nix-rice-lib; };
  paletteTests = import ./palette.nix { inherit nix-rice-lib; };
  kittyTests = import ./kitty-themes.nix { inherit nix-rice-lib; };
in
opTests ++ floatTests ++ hexTests ++ colorTests ++ paletteTests ++ kittyTests
