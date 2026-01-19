{ nix-rice-lib }:
let
  inherit (nix-rice-lib) palette color;
  testPalette = {
    red = "#FF0000FF";
    green = "#00FF00FF";
    blue = "#0000FFFF";
  };
  rgbaPalette = palette.tPalette color.hexToRgba testPalette;
in
[
  "All palette tests passed:\n"
  (assert (palette.brighten 10 rgbaPalette).red.r == 255.0; "\tbrighten palette red unchanged\n")
  (assert (palette.brighten 10 rgbaPalette).green.g == 255.0; "\tbrighten palette green clamped\n")
  (assert (palette.brighten 10 rgbaPalette).blue.b == 255.0; "\tbrighten palette blue\n")
  (assert (palette.darken 10 rgbaPalette).red.r == 245; "\tdarken palette\n")
  (assert (palette.toRgbHex rgbaPalette).red == "#ff0000"; "\ttoRgbHex palette\n")
]
