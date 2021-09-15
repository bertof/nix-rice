# nix-rice

Bring ricing to Nix!

## Why

Nix standard library does not have direct support for colors and their hexadecimal representation, commonly used in package configurations. This library tries to solve this by adding:

- Support to common float operations
- Support to color definitions and transformations (RGBA and HSLA)
- Color serialisation and deserialisation as hexadecimal strings
- Color palette definitions and transformations

## How to use it

An example integration to a home-manager configuration is shown inside the [home-manager](./home-manager) folder.
The library is built using only builtin functions and the [standard nix library](https://github.com/NixOS/nixpkgs/tree/master/lib) and can be easily used even in single derivations as an overlay.

```nix
final: prev:
let
  # Fetch library
  nix-rice = final.callPackage (
    fetchTarball {
      url = "https://github.com/bertof/nix-rice/archive/refs/tags/v0.2.1.tar.gz";
      sha256 = "1is70gjf59sxccwhz1hl9hdxsd4z8vqsr2rdk3imnmxj9n3jf6j8";
    }
  ) {};
  # Parse theme
  nord = with nix-rice; palette.tPalette color.hexToRgba (import ../themes/nord.nix);
in
(
  rec {
    # Build a derivation to hold the ricing
    rice = nix-rice // {
      # Define the color palette
      # You can use any form of map you prefere
      # Palette transform functions are applied recursively, including serialisation and deserialisation
      colorPalette = with nix-rice; rec {
        normal = {
          black = nord.n1;
          blue = nord.n10;
          cyan = nord.n8;
          green = nord.n14;
          magenta = nord.n15;
          red = nord.n11;
          white = nord.n5;
          yellow = nord.n13;
        };
        # Use a generated brighter palette and override some colors
        bright = palette.brighten 10 normal // {
          blue = nord.n9;
          black = nord.n2;
          red = nord.n12;
          white = nord.n6;
        };
        dark = palette.darken 10 normal // {
          black = nord.n0;
          blue = nord.n3;
          cyan = nord.n7;
          white = nord.n4;
        };
      };
      # Font configurations uses the same pattern in home-manager
      font = {
        normal = {
          name = "Cantarell";
          package = final.cantarell-fonts;
          size = 10;
        };
        monospace = {
          name = "FuraCode Nerd Font Mono";
          package = (
            final.nerdfonts.override {
              fonts = [ "FiraCode" ];
            }
          );
          size = 10;
        };
      };
      # The ricing may contain any kind of information you want to pass to your configurations
      opacity = 0.95;
    };
  }
)
```

While the library interface is mostly set, it might change in the future (new transformations, palette generation, conversion to specific programs configurations). It is therefore suggested to use a pinned version like in the example above.


## Contributions

Feel free to modify this library as you please: addition and fixes are welcome. Want to include your favourite theme? Add a new transformation? Send a PR.
