final: prev:
let
  nix-rice = final.callPackage (
    fetchTarball {
      url = "https://github.com/bertof/nix-rice/archive/refs/tags/v0.2.0.tar.gz";
      sha256 = "1spv4i753abrswbzawdc2rh8889s09njk1nbjdzvlp731prrr2yh";
    }
  ) {};
  nord = import ../themes/nord.nix;
  onedark = import ../themes/onedark.nix;
in
(
  rec {
    rice = nix-rice // {
      colorPalette = with nix-rice; rec {
        normal = {
          black = color.hexToRgba nord.n0;
          red = color.hexToRgba nord.n11;
          green = color.hexToRgba nord.n14;
          yellow = color.hexToRgba nord.n13;
          blue = color.hexToRgba nord.n10;
          magenta = color.hexToRgba nord.n15;
          cyan = color.hexToRgba nord.n8;
          white = color.hexToRgba nord.n4;
        };
        bright = palette.brighten 10 normal // {
          white = color.hexToRgba nord.n6;
          red = color.hexToRgba nord.n12;
        };
        dark = palette.darken 10 normal;
      };
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
      opacity = 0.9;
    };
  }
)
