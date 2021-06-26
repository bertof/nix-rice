{ pkgs, lib ? pkgs.lib, ... }:
let
  inherit (builtins) abort isFloat isInt;
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
  inRange = a: b: v:
    let
      ub = max a b;
      lb = min a b;
    in
      (v <= ub) && (v >= lb);

  # Clamp `v` between `a` and `b`
  clamp = a: b: v:
    let
      ub = max a b;
      lb = min a b;
    in
      min (max v lb) ub;
}
