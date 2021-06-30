# Example integration with home-assistant
{ pkgs, lib, ... }:

let
  # Callpackage with the default packages
  callPackage = pkgs.lib.callPackageWith pkgs;
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
    (final: prev: { rice = (prev.lib.callPackageWith prev) nix-rice {}; }) # Custom library
    (final: prev: (prev.lib.callPackageWith prev) ./custom/default.nix {}) # Custom packages
    (
      final: prev: rec {
        rice = prev.rice // {
          # Building a palette and assigning it as a custom derivation
          colorPalette = with pkgs.rice; palette.palette rec {
            black = color.hexToRgba nord.n0;
            red = color.hexToRgba nord.n11;
            green = color.hexToRgba nord.n14;
            yellow = color.hexToRgba nord.n13;
            blue = color.hexToRgba nord.n10;
            magenta = color.hexToRgba nord.n15;
            cyan = color.hexToRgba nord.n8;
            white = color.hexToRgba nord.n4;

            bright-white = color.hexToRgba nord.n6;
            bright-red = color.hexToRgba nord.n12;
            cursor-cursor = color.hexToRgba nord.n4;

            primary-background = color.tAlphaRgba (v: float.round (255 * opacity)) black;
          };
          # We define here also the default fonts used throughout the configuration
          font = {
            normal = { package = pkgs.cantarell-fonts; name = "Cantarell"; };
            monospace = { package = pkgs.nerdfonts; name = "FuraCode Nerd Font Mono"; };
          };
          # It's usefull to define the opacity for semi-transparent backgrounds in a
          # single place like this
          opacity = 0.9;
        };
      }
    )
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
