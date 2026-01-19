{ nix-rice-lib }:
let inherit (nix-rice-lib) op;
in [
  "All op tests passed:\n"
  (assert op.isNumber 5; "\tisNumber integer\n")
  (assert op.isNumber 5.0; "\tisNumber float\n")
  (assert !op.isNumber "5"; "\tisNumber string false\n")
  (assert op.abs (-5) == 5; "\tabs positive\n")
  (assert op.abs 5 == 5; "\tabs already positive\n")
  (assert op.clamp 0 10 5 == 5; "\tclamp in range\n")
  (assert op.clamp 0 10 (-5) == 0; "\tclamp below min\n")
  (assert op.clamp 0 10 15 == 10; "\tclamp above max\n")
  (assert op.inRange 0 10 5; "\tinRange true\n")
  (assert !op.inRange 0 10 15; "\tinRange false\n")
]
