self: super: { lib = super.lib // { rice = self.callPackage ./default.nix { }; }; }
