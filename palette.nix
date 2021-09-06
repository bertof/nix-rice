{ pkgs, color, lib, ... }:
let
  inherit (builtins) isString;
  inherit (lib.attrsets) mapAttrsRecursiveCond;
in
rec{

  # Palette constructor
  # Produces a palette of colors starting from sane defaults
  # Override the inputs with your favorite colors
  #
  # Ex: palette.defaultPalette => { black = { ... }; blue = { ... }; cyan = { ... }; green = { ... }; magenta = { ... }; red = { ... }; white = { ... }; yellow = { ... }; }
  defaultPalette = with color; {
    black = rgba black;
    red = rgba red;
    green = rgba green;
    yellow = rgba yellow;
    blue = rgba blue;
    magenta = rgba magenta;
    cyan = rgba cyan;
    white = rgba white;
  };

  ## TRANSFORM
  # Map palette applying a transform
  tPalette = f: p: mapAttrsRecursiveCond (v: !color.isRgba v) (a: v: f v) p;

  # Brighten a palette
  brighten = value: palette: tPalette (color.brighten value) palette;

  # Darken a palette
  darken = value: palette: tPalette (color.darken value) palette;

  ## SERIALIZATION
  # Try to convert input colors to a lowercase hex encoded RGBA color
  toRgbaHex = tPalette color.toRgbaHex;

  # Try to convert input colors to a uppercase hex encoded RGBA color
  toRGBAHex = tPalette color.toRGBAHex;

  # Try to convert input colors to a lowercase hex encoded RGB color
  toRgbHex = tPalette color.toRgbHex;

  # Try to convert input colors to a lowercase hex encoded RGB color
  toRGBHex = tPalette color.toRGBHex;

  # Try to convert input colors to a uppercase hex encoded RGB color in the form ARGB (Polybar uses this format)
  toARGBHex = tPalette color.toARGBHex;

  # Try to convert input colors to a lowercase hex encoded RGB color in the form argb (Polybar uses this format)
  toArgbHex = tPalette color.toArgbHex;

  # Try to convert input colors to a lowercase hex encoded RGBA color
  toRgbaShortHex = tPalette color.toRgbaShortHex;

  # Try to convert input colors to a uppercase hex encoded RGBA color
  toRGBAShortHex = tPalette color.toRGBAShortHex;

  # Try to convert input colors to a lowercase hex encoded RGB color
  toRgbShortHex = tPalette color.toRgbShortHex;

  # Try to convert input colors to a lowercase hex encoded RGB color
  toRGBShortHex = tPalette color.toRGBShortHex;

  # Try to convert input colors to a uppercase hex encoded RGB color in the form ARGB (Polybar uses this format)
  toARGBShortHex = tPalette color.toARGBShortHex;

  # Try to convert input colors to a lowercase hex encoded RGB color in the form argb (Polybar uses this format)
  toArgbShortHex = tPalette color.toArgbShortHex;

}
