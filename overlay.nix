self: super: { lib = super.lib // { rice = self.callPackage ./lib.nix { }; }; }
