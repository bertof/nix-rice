{ pkgs, lib ? pkgs.lib, hex, float, op, ... }:
let
  inherit (builtins) add div fromJSON getAttr hasAttr isAttrs isFloat isInt isString sub trace;
  inherit (float) mod' round toFloat;
  inherit (hex) fromDec;
  inherit (lib.lists) all drop head last tail;
  inherit (lib.strings) concatMapStrings fixedWidthString match toInt toLower;
  inherit (lib.trivial) max min;
  inherit (op) abs clamp inRange isNumber;

  ## 8BIT
  # Check if `v` is in 8Bit format
  _is8Bit = inRange 0.0 255.0;

  # Clamp 8bit value
  _clamp8Bit = clamp 0.0 255.0;

  # Apply function to 8bit value and clamp the result
  _tclamp8Bit = f: v: _clamp8Bit (f v);

  ## UNARY
  # Check if input is in [0, 1]
  _isUnary = inRange 0.0 1.0;

  # Clamp input to [0, 1]
  _clampUnary = clamp 0.0 1.0;

  # Apply function to unary value and clamp the result
  _tclampUnary = f: v: _clampUnary (f v);

  # Check if input is in [0, 360]
  _isHue = inRange 0.0 360.0;

  # Apply function to hue value and map the result in [0, 360)
  _tHue = f: v: mod' (f v) 360.0;

  # Convert 8bit value to a 2 digit hex string without initial #
  _toShortHex = values:
    assert(all _is8Bit values);
    ''${concatMapStrings (v: fixedWidthString 2 "0" (fromDec (round (toFloat v)))) values}'';

  # Convert 8bit value to a 2 digit hex string
  _toHex = values: "#${_toShortHex values}";

  # Parse input for hex triplet
  #
  # Es: _match3hex "#001122" => ["00" "11" "22"]
  _match3hex = match "#([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})";

  # Parse input for hex quadruplet
  #
  # Es: _match3hex "#00112233" => ["00" "11" "22" "33"]
  _match4hex = match "#([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})([[:xdigit:]]{2})";

  # Apply an operator using a possibly relative operand
  _relative_operator = operator: prev: value:
    let
      percentMatches = match "[[:space:]]*(-?[[:digit:]]+\.?[[:digit:]]*)%[[:space:]]*" value;
      percentValue = if percentMatches != null then fromJSON (head percentMatches) else null;
    in
    if isNumber value then operator prev value           # If the input is a number, apply it directly
    else prev * ((operator 100.0 percentValue) / 100.0); # Else if the input is a percentage apply it relatively to the original input

  _relative_addition = _relative_operator add;
  _relative_subtraction = _relative_operator sub;

in
rec {

  # RGBA constructor
  #
  # Uses [0,255] float representation for all fields
  rgba = { r, g, b, a ? 255.0 }:
    let
      c = { inherit r g b a; };
    in
    assert(isRgba c); c;

  # HSLA constructor
  #
  # Uses [0, 360) float representation for h
  # Uses [0,1] float representation for s l and a
  hsla = { h, l, s, a ? 1.0 }:
    let
      c = { inherit h s l a; };
    in
    assert(isHsla c); c;

  # Check if input is a valid RGBA color
  isRgba = c:
    let
      hasAttributes = all (k: hasAttr k c) [ "r" "g" "b" "a" ];
      validRanges = all (k: _is8Bit (getAttr k c)) [ "r" "g" "b" "a" ];
    in
    hasAttributes && validRanges;

  # Check if input is a valid HSLA color
  isHsla = c:
    let
      hasAttributes = all (k: hasAttr k c) [ "h" "s" "l" "a" ];
      validRanges = _isHue c.h && all (k: _isUnary (getAttr k c)) [ "s" "l" "a" ];
    in
    hasAttributes && validRanges;

  ## CONVERSION
  # RGBA to HSLA
  rgbaToHsla = color:
    let
      c_color = rgba color;
      r = c_color.r / 255.0;
      g = c_color.g / 255.0;
      b = c_color.b / 255.0;
      a = c_color.a / 255.0;
      c_min = min (min r g) b;
      c_max = max (max r g) b;
      delta = c_max - c_min;

      hue = (
        if delta == 0.0 then 0.0 else
        if r == c_max then (mod' (((g - b) / delta) + 6) 6) else
        if g == c_max then (b - r) / delta + 2 else
          assert b == c_max; (r - g) / delta + 4
      ) * 60;
      lightness = (c_min + c_max) / 2.0;
      saturation =
        if delta == 0.0 then 0.0 else
        delta / (1 - abs (2.0 * lightness - 1.0));
    in
    assert (isRgba color);
    hsla {
      l = _clampUnary lightness;
      s = _clampUnary saturation;
      h = mod' hue 360.0;
      a = _clampUnary a;
    };

  # HSLA to RGBA
  hslaToRgba = color:
    assert (isHsla color);
    let
      # check if `v` is in [a, b)
      # _checkRange = a: b: v: a <= v && v < b;
      inherit (hsla color) h s l a;
      c = (1 - (abs (2 * l - 1))) * s;
      x = c * (1 - abs ((mod' (h / 60) 2) - 1));
      m = l - (c / 2.0);

      r' = if inRange 120 240 h then 0 else
      if inRange 60 300 h then x else
      c;
      g' = if inRange 60 180 h then c else
      if inRange 0 240 h then x else
      0;
      b' = if inRange 180 300 h then c else
      if inRange 120 360 h then x else
      0;
    in
    rgba {
      r = (r' + m) * 255.0;
      g = (g' + m) * 255.0;
      b = (b' + m) * 255.0;
      a = a * 255.0;
    };


  ## TRANSFORM PRIMITIVES

  # Apply a function to one of the RGBA parameters
  # Automatically checks the input and clamps the output to a valid RGBA color
  tRedRgba = f: color: assert (isRgba color); color // { r = _tclamp8Bit f color.r; };
  tGreenRgba = f: color: assert (isRgba color); color // { g = _tclamp8Bit f color.g; };
  tBlueRgba = f: color: assert (isRgba color); color // { b = _tclamp8Bit f color.b; };
  tAlphaRgba = f: color: assert (isRgba color); color // { a = _tclamp8Bit f color.a; };

  # Set functions for RGBA colors
  setRedRgba = r: tRedRgba (_: r);
  setGreenRgba = g: tGreenRgba (_: g);
  setBlueRgba = b: tBlueRgba (_: b);
  setAlphaRgba = a: tAlphaRgba (_: a);

  # Apply a function to one of the HSLA parameters
  # Automatically checks the input and clamps the output to a valid HSLA color
  tHueHsla = f: color: assert (isHsla color); color // { h = _tHue f color.h; };
  tSaturationnHsla = f: color: assert (isHsla color); color // { s = _tclampUnary f color.s; };
  tLightnessHsla = f: color: assert (isHsla color); color // { l = _tclampUnary f color.l; };
  tAlphaHsla = f: color: assert (isHsla color); color // { a = _tclampUnary f color.a; };

  # Set functions for HSLA colors
  setHueHsla = h: tHueHsla (_: h);
  setSaturationnHsla = s: tSaturationnHsla (_: s);
  setLightnessHsla = l: tLightnessHsla (_: l);
  setAlphaHsla = a: tAlphaHsla (_: a);

  ## RGB TRANSFORM
  # Add brightness as number value or relative percent value
  # Allows both positive and negative values
  #
  # Es: brighten 10.2 red => { a = 255; b = 10.2; g = 10.2; r = 255; }
  # Es: brighten "-10%" white => { a = 255; b = 229.5; g = 229.5; r = 229.5; }
  brighten = value:
    let
      valueTransform = v: _relative_addition v value;
    in
    color: tBlueRgba valueTransform (tGreenRgba valueTransform (tRedRgba valueTransform color));

  # Subtract brightness as number value or relative percent value
  # Allows both positive and negative values
  #
  # Es: darken 10.2 red => { a = 255; b = 229.5; g = 229.5; r = 229.5; }
  # Es: darken "10%" white => { a = 255; b = 229.5; g = 229.5; r = 229.5; }
  darken = value:
    let
      valueTransform = v: _relative_subtraction v value;
    in
    color: tBlueRgba valueTransform (tGreenRgba valueTransform (tRedRgba valueTransform color));


  ## HSLA transform
  # Shft HSLA hue by a number value or relative percent value
  #
  # Es: shiftHue 120 (rgbaToHsla red) = { a = 1; h = 120; l = 0.5; s = 1; }
  # Es: shiftHue "100%" (rgbaToHsla green) = { a = 1; h = 240; l = 0.5; s = 1; }
  shiftHue = value: tHueHsla (h: _relative_addition h value);


  ## DESERIALIZATION
  # Parse a hex color string to a RGBA color
  #
  # Es: hexToRgba "#0000FF" => { a = 255; b = 255; g = 0; r = 0; }
  # Es: hexToRgba "#00FF0055" => { a = 85; b = 0; g = 255; r = 0; }
  hexToRgba = s:
    let
      rgbaVal = _match4hex s;
      rgbVal = _match3hex s;
      hex_list = if null == rgbVal then rgbaVal else rgbVal ++ [ "FF" ];
      values = map (s: toFloat (hex.toDec s)) hex_list;
    in
    rgba {
      r = head values;
      g = head (tail values);
      b = head (drop 2 values);
      a = last values;
    };


  ## SERIALIZATION
  # Print RGB color as uppercase hex string
  toRGBHex = color:
    assert (isRgba color);
    _toHex [ color.r color.g color.b ];

  # Print RGBA color as uppercase hex string
  toRGBAHex = color:
    assert (isRgba color);
    _toHex [ color.r color.g color.b color.a ];

  # Print RGBA color as uppercase hex string in the form ARGB (Polybar uses this format)
  toARGBHex = color:
    assert (isRgba color);
    _toHex [ color.a color.r color.g color.b ];

  # Print RGB color as lowercase hex string
  toRgbHex = color: toLower (toRGBHex color);

  # Print RGBA color as lowercase hex string
  toRgbaHex = color: toLower (toRGBAHex color);

  # Print RGBA color as lowercase hex string in the form argb (Polybar uses this format)
  toArgbHex = color: toLower (toArgbHex color);

  # Print RGB color as uppercase short hex string
  toRGBShortHex = color:
    assert (isRgba color);
    _toShortHex [ color.r color.g color.b ];

  # Print RGBA color as uppercase short hex string
  toRGBAShortHex = color:
    assert (isRgba color);
    _toShortHex [ color.r color.g color.b color.a ];

  # Print RGBA color as uppercase short hex string in the form ARGB (Polybar uses this format)
  toARGBShortHex = color:
    assert (isRgba color);
    _toShortHex [ color.a color.r color.g color.b ];

  # Print RGB color as lowercase short hex string
  toRgbShortHex = color: toLower (toRGBShortHex color);

  # Print RGBA color as lowercase short hex string
  toRgbaShortHex = color: toLower (toRGBAShortHex color);

  # Print RGBA color as lowercase short hex string in the form argb (Polybar uses this format)
  toArgbShortHex = color: toLower (toArgbShortHex color);

  ## CONSTANTS
  black = hexToRgba "#000000"; #         RGB (0,0,0)       HSL (0°,0%,0%)
  white = hexToRgba "#FFFFFF"; #         RGB (255,255,255) HSL (0°,0%,100%)
  red = hexToRgba "#FF0000"; #           RGB (255,0,0)     HSL (0°,100%,50%)
  green = hexToRgba "#00FF00"; #         RGB (0,255,0)     HSL (120°,100%,50%)
  blue = hexToRgba "#0000FF"; #          RGB (0,0,255)     HSL (240°,100%,50%)
  yellow = hexToRgba "#FFFF00"; #        RGB (255,255,0)   HSL (60°,100%,50%)
  cyan = hexToRgba "#00FFFF"; #          RGB (0,255,255)   HSL (180°,100%,50%)
  magenta = hexToRgba "#FF00FF"; #       RGB (255,0,255)   HSL (300°,100%,50%)
  transparent = hexToRgba "#00000000"; # RGBA (0,0,0,0)    HSLA (0°,0%,0%,0%)
}
