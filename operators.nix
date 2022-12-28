{ lib, ... }:
let
  inherit (builtins) isFloat isInt;
  inherit (lib.trivial) max min;
in
rec {
  # Check if input is a number
  isNumber = v: isInt v || isFloat v;

  # Absolute operator
  abs = v:
    assert(isNumber v);
    if v < 0 then (-v) else v;

  # Check if `v` is between `a` and `b`
  inRange = a: b: v: (v <= max a b) && (v >=min a b);

  # Clamp `v` between `a` and `b`
  clamp = a: b: v: min (max v (min a b)) (max a b);
}
