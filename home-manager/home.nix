# Example integration with home-assistant
{
  nixpkgs.overlays = [
    (import ./overlay.nix) # rice overlay
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
