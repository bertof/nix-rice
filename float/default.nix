{ pkgs, lib ? pkgs.lib, op, ... }:
let
  inherit (builtins) fromJSON head isFloat isInt isString;
  inherit (lib.strings) splitString toInt;
  inherit (op) isNumber;
in
rec {

  # Converts the input to a float if possible (hacky but it works)
  toFloat = v:
    let
      strVal = fromJSON v;
      forceFloat = i: if isFloat i then i else i + 0.5 - 0.5;
    in
      assert (isNumber v || isString v);
      if isString v then forceFloat strVal
      else if isInt v then forceFloat v
      else v;

  # Round float to lower integer
  floor = f:
    let
      floatComponents = splitString "." (toString f);
      int = toInt (head (floatComponents));
    in
      assert(isFloat f);
      int;

  # Round float to upper integer
  ceil = f:
    let
      int = div' f 1;
      inc = if mod' f 1 > 0 then 1 else 0;
    in
      assert(isFloat f);
      int + inc;

  # Round float to closest integer
  round = f:
    let
      int = div' f 1;
      inc = if mod' f 1 >= 0.5 then 1 else 0;
    in
      assert(isFloat f);
      int + inc;

  # Integer division for floats
  div' = n: d:
    assert(isNumber n);
    assert(isNumber d);
    floor (builtins.div (toFloat n) (toFloat d));

  # Module operator implementation for floats
  mod' = n: d:
    let
      f = div' n d;
    in
      assert(isNumber n);
      assert(isNumber d);
      n - (toFloat f) * d;
}
