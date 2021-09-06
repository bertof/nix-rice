# Example integration with home-assistant
{ pkgs, lib, ... }:

let
  # Import the nix-rice library. In this case I'm pinning the version.
  nix-rice = fetchTarball {
    url = "https://github.com/bertof/nix-rice/archive/refs/tags/v0.1.1.tar.gz";
    sha256 = "07pdvdc1z1nl8vm0w689nwrncr0f09c55f7cr7272rs5pbmjdza6";
  };
  # Import your favourite theme
  nord = import ./themes/nord.nix;
in
{
  nixpkgs.overlays = [
    (import ./overlay.nix) # rice overlay
    (final: prev: (prev.lib.callPackageWith prev) ./custom/default.nix {}) # Custom packages
    (
      final: prev: {
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
