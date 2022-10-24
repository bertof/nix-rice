final: prev:
let
  # nord = prev.lib.rice.palette.tPalette prev.lib.rice.color.hexToRgba (import ./themes/nord.nix);
  # onedark = prev.lib.rice.palette.tPalette prev.lib.rice.color.hexToRgba (import ./themes/onedark.nix);
  # tomorrow-night = prev.lib.rice.palette.tPalette prev.lib.rice.color.hexToRgba (import ./themes/tomorrow-night.nix);
  # mkpm = with prev.lib.rice; palette.tPalette color.hexToRgba (import ./themes/monokai-pro-machine.nix);
  # bloom = with prev.lib.rice;
  #   palette.tPalette color.hexToRgba (import ./themes/bloom.nix);
  ayu-mirage = with prev.lib.rice; palette.tPalette color.hexToRgba (import ../themes/ayu-mirage.nix);
in
rec {
  rice = {
    colorPalette = with prev.lib.rice; rec {
      normal = palette.defaultPalette // {
        inherit (ayu-mirage.normal) black red green yellow blue magenta cyan white;
      };
      bright = palette.brighten 10 normal // {
        inherit (ayu-mirage.bright) black red green yellow blue magenta cyan white;
      };
      dark = palette.darken 10 normal;
      primary = {
        background = color.black;
        foreground = color.white;
        bright_foreground = color.white;
        dim_foreground = dark.white;
      } // ayu-mirage.primary;
    };
    font = {
      normal = {
        name = "Cantarell";
        package = final.cantarell-fonts;
        size = 10;
      };
      monospace = {
        name = "FiraCode Nerd Font Mono";
        package = final.nerdfonts.override { fonts = [ "FiraCode" ]; };
        size = 10;
      };
    };
    opacity = 0.95;
  };
}
