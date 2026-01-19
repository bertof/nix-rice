{ nix-rice-lib }:
let
  inherit (nix-rice-lib) color;
  redRgba = color.rgba {
    r = 255;
    g = 0;
    b = 0;
    a = 255;
  };
  greenHsla = color.hsla {
    h = 120;
    s = 1.0;
    l = 0.5;
    a = 1.0;
  };
in
[
  "All color tests passed:\n"
  (assert color.isRgba redRgba; "\tisRgba\n")
  (assert color.isHsla greenHsla; "\tisHsla\n")
  (assert color.rgbaToHsla redRgba == { h = 0.0; s = 1.0; l = 0.5; a = 1.0; }; "\trgbaToHsla red\n")
  (assert color.hslaToRgba greenHsla == { r = 0.0; g = 255.0; b = 0.0; a = 255.0; }; "\thslaToRgba green\n")
  (assert color.brighten 10 redRgba == { r = 255.0; g = 10.0; b = 10.0; a = 255.0; }; "\tbrighten rgba\n")
  (assert color.darken 10 redRgba == { r = 245.0; g = 0.0; b = 0.0; a = 255.0; }; "\tdarken rgba\n")
  (assert color.shiftHue 60 greenHsla == { h = 180.0; s = 1.0; l = 0.5; a = 1.0; }; "\tshiftHue\n")
  (assert color.toRgbHex redRgba == "#ff0000"; "\ttoRgbHex\n")
  (assert color.toRgbaHex redRgba == "#ff0000ff"; "\ttoRgbaHex\n")
  (assert color.hexToRgba "#FF0000" == { r = 255.0; g = 0.0; b = 0.0; a = 255.0; }; "\thexToRgba\n")
]
