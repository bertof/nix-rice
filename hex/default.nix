{ pkgs, lib ? pkgs.lib, ... }:
let
  inherit (builtins) getAttr hasAttr;
  inherit (lib.lists) foldl;
  inherit (lib.strings) stringToCharacters toUpper;
  inherit (lib.trivial) toHexString;

  # Parse a single hexadecimal digit to an integer
  _parseDigit = c:
    let
      k = toUpper c;
      dict = {
        "0" = 0;
        "1" = 1;
        "2" = 2;
        "3" = 3;
        "4" = 4;
        "5" = 5;
        "6" = 6;
        "7" = 7;
        "8" = 8;
        "9" = 9;
        "A" = 10;
        "B" = 11;
        "C" = 12;
        "D" = 13;
        "E" = 14;
        "F" = 15;
      };
    in
      assert(hasAttr k dict);
      getAttr k dict;

in
rec {

  # Convert an hexadecimal string to an integer
  toDec = s:
    let
      characters = stringToCharacters s;
      values = map _parseDigit characters;
    in
      foldl (acc: n: acc * 16 + n) 0 values;

  # Convert an integer to a decimal string
  fromDec = toHexString;

}
