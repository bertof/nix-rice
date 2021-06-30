{ pkgs, color, lib, ... }:
let
  inherit (builtins) isString;
  inherit (lib.attrsets) mapAttrsRecursiveCond;
  inherit (color) rgba;
in
rec{

  # Palette constructor
  # Produces a palette of colors starting from sane defaults
  # Override the inputs with your favorite colors
  palette =
    { black ? color.black
    , red ? color.red
    , green ? color.green
    , yellow ? color.yellow
    , blue ? color.blue
    , magenta ? color.magenta
    , cyan ? color.cyan
    , white ? color.white
    , bright-black ? color.brighten black 10
    , bright-red ? color.brighten red 10
    , bright-green ? color.brighten green 10
    , bright-yellow ? color.brighten yellow 10
    , bright-blue ? color.brighten blue 10
    , bright-magenta ? color.brighten magenta 10
    , bright-cyan ? color.brighten cyan 10
    , bright-white ? color.brighten white 10
    , dim-black ? color.darken black 10
    , dim-red ? color.darken red 10
    , dim-green ? color.darken green 10
    , dim-yellow ? color.darken yellow 10
    , dim-blue ? color.darken blue 10
    , dim-magenta ? color.darken magenta 10
    , dim-cyan ? color.darken cyan 10
    , dim-white ? color.darken white 10
    , primary-background ? black
    , primary-foreground ? white
    , primary-dim_foreground ? dim-white
    , cursor-text ? black
    , cursor-cursor ? white
    , vi-cursor-text ? cursor-text
    , vi-cursor-cursor ? cursor-cursor
    }: {
      normal = {
        black = rgba black;
        red = rgba red;
        green = rgba green;
        yellow = rgba yellow;
        blue = rgba blue;
        magenta = rgba magenta;
        cyan = rgba cyan;
        white = rgba white;
      };
      bright = {
        black = rgba bright-black;
        red = rgba bright-red;
        green = rgba bright-green;
        yellow = rgba bright-yellow;
        blue = rgba bright-blue;
        magenta = rgba bright-magenta;
        cyan = rgba bright-cyan;
        white = rgba bright-white;
      };
      dim = {
        black = rgba dim-black;
        red = rgba dim-red;
        green = rgba dim-green;
        yellow = rgba dim-yellow;
        blue = rgba dim-blue;
        magenta = rgba dim-magenta;
        cyan = rgba dim-cyan;
        white = rgba dim-white;
      };
      primary = {
        background = rgba primary-background;
        foreground = rgba primary-foreground;
        dim_foreground = rgba primary-dim_foreground;
      };
      cursor = {
        cursor = rgba cursor-cursor;
        text = rgba cursor-text;
      };
      vi_mode_cursor = {
        cursor = rgba cursor-cursor;
        text = rgba cursor-text;
      };
    };


  ## TRANSFORM
  tPalette = f: p: mapAttrsRecursiveCond (v: !color.isRgba v) (a: v: f v) p;

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
}
