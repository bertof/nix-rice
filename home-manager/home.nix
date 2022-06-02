# Example integration with home-assistant
{
  nixpkgs.overlays = [

    (
      import
        (fetchTarball {
          url = "https://github.com/bertof/nix-rice/archive/refs/tags/v0.2.0.tar.gz";
          sha256 = "1spv4i753abrswbzawdc2rh8889s09njk1nbjdzvlp731prrr2yh";
        }) + ./overlay.nix
    ) # nix rice overlay
    (_: prev: (prev.lib.callPackageWith prev) ./custom/default.nix { }) # Custom packages
    (
      _: prev: {
        # Override the lockscreen script derivation with our custom palette and fonts
        lockscreen = prev.lockscreen.override {
          palette = prev.rice.colorPalette;
          font = prev.rice.font.normal;
        };
      }
    )
  ];

  # Inclusion of the programs modules
  imports = [
    ./modules/alacritty.nix
    ./modules/polybar.nix
  ];
}
