self: super: { lib = super.lib // { nix-rice = self.callPackage ./lib.nix { }; }; }
