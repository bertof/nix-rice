{ pkgs, color, lib, ... }:
let
  inherit (builtins) isString;
  inherit (lib.attrsets) mapAttrsRecursiveCond;
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
    , bright-black ? color.brighten black "10%"
    , bright-red ? color.brighten red "10%"
    , bright-green ? color.brighten green "10%"
    , bright-yellow ? color.brighten yellow "10%"
    , bright-blue ? color.brighten blue "10%"
    , bright-magenta ? color.brighten magenta "10%"
    , bright-cyan ? color.brighten cyan "10%"
    , bright-white ? color.brighten white "10%"
    , dim-black ? color.darken black "10%"
    , dim-red ? color.darken red "10%"
    , dim-green ? color.darken green "10%"
    , dim-yellow ? color.darken yellow "10%"
    , dim-blue ? color.darken blue "10%"
    , dim-magenta ? color.darken magenta "10%"
    , dim-cyan ? color.darken cyan "10%"
    , dim-white ? color.darken white "10%"
    , primary-background ? black
    , primary-foreground ? white
    , primary-dim_foreground ? color.darken primary-foreground "10%"
    , cursor-text ? primary-background
    , cursor-cursor ? primary-foreground
    , vi-cursor-text ? cursor-text
    , vi-cursor-cursor ? cursor-cursor
    }: {
      normal = {
        black = assert(color.isRgba black); black;
        red = assert(color.isRgba red); red;
        green = assert(color.isRgba green); green;
        yellow = assert(color.isRgba yellow); yellow;
        blue = assert(color.isRgba blue); blue;
        magenta = assert(color.isRgba magenta); magenta;
        cyan = assert(color.isRgba cyan); cyan;
        white = assert(color.isRgba white); white;
      };
      bright = {
        black = assert(color.isRgba bright-black); bright-black;
        red = assert(color.isRgba bright-red); bright-red;
        green = assert(color.isRgba bright-green); bright-green;
        yellow = assert(color.isRgba bright-yellow); bright-yellow;
        blue = assert(color.isRgba bright-blue); bright-blue;
        magenta = assert(color.isRgba bright-magenta); bright-magenta;
        cyan = assert(color.isRgba bright-cyan); bright-cyan;
        white = assert(color.isRgba bright-white); bright-white;
      };
      dim = {
        black = assert(color.isRgba dim-black); dim-black;
        red = assert(color.isRgba dim-red); dim-red;
        green = assert(color.isRgba dim-green); dim-green;
        yellow = assert(color.isRgba dim-yellow); dim-yellow;
        blue = assert(color.isRgba dim-blue); dim-blue;
        magenta = assert(color.isRgba dim-magenta); dim-magenta;
        cyan = assert(color.isRgba dim-cyan); dim-cyan;
        white = assert(color.isRgba dim-white); dim-white;
      };
      primary = {
        background = assert(color.isRgba primary-background); primary-background;
        foreground = assert(color.isRgba primary-foreground); primary-foreground;
        dim_foreground = assert(color.isRgba primary-dim_foreground);primary-dim_foreground;
      };
      cursor = {
        cursor = assert(color.isRgba cursor-cursor); cursor-cursor;
        text = assert(color.isRgba cursor-text); cursor-text;
      };
      vi_mode_cursor = {
        cursor = assert(color.isRgba cursor-cursor); cursor-cursor;
        text = assert(color.isRgba cursor-text); cursor-text;
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
