final: prev: { lib = prev.lib // { rice = final.callPackage ./default.nix { }; }; }
