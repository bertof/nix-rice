{ nix-rice-lib }:
let inherit (nix-rice-lib) hex;
in [
  "All hex tests passed\n"
  (assert hex.toDec "FF" == 255; "\ttoDec FF\n")
  (assert hex.toDec "10" == 16; "\ttoDec 10\n")
  (assert hex.fromDec 255 == "FF"; "\tfromDec 255\n")
  (assert hex.fromDec 16 == "10"; "\tfromDec 16\n")
]
