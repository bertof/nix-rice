{ nix-rice-lib }:
let
  inherit (nix-rice-lib) kitty-themes;
  theme = kitty-themes.getThemeByName "Catppuccin-Mocha";
in
[
  "All kitty-themes tests passed:\n"
  (assert theme != null; "\tgetThemeByName returns theme\n")
  (assert builtins.isAttrs theme; "\ttheme is attrs\n")
  (assert theme ? color0; "\ttheme has color0\n")
]
