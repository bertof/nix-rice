{ nix-rice-lib }:
let inherit (nix-rice-lib) float;
in [
  "All float tests passed:\n"
  (assert float.toFloat 5 == 5.0; "\ttoFloat int\n")
  (assert float.toFloat 5.5 == 5.5; "\ttoFloat float\n")
  (assert float.floor 5.7 == 5; "\tfloor\n")
  (assert float.ceil 5.1 == 6; "\tceil\n")
  (assert float.round 5.4 == 5; "\tround down\n")
  (assert float.round 5.5 == 6; "\tround up\n")
  (assert float.div' 10 3 == 3; "\tdiv' integer\n")
  (assert float.mod' 10 3 == 1; "\tmod' integer\n")
  (assert float.mod' 10.5 3 == 1.5; "\tmod' float\n")
]
