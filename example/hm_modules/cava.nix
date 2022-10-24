{ pkgs, lib, ... }:
let
  strPalette = with pkgs.rice; pkgs.lib.rice.palette.toRgbHex colorPalette;
  fmtString = str: "'${str}'";
in
{
  home.packages = [ pkgs.cava ];

  xdg.configFile."cava/config".text = lib.generators.toINI { } {
    general = {
      bar_width = 1;
      bar_spacing = 1;
    };
    color = {
      gradient = 1;
      gradient_count = 5;
      gradient_color_1 = fmtString strPalette.normal.red;
      gradient_color_2 = fmtString strPalette.normal.yellow;
      gradient_color_3 = fmtString strPalette.normal.white;
      gradient_color_4 = fmtString strPalette.normal.cyan;
      gradient_color_5 = fmtString strPalette.normal.blue;
    };
    smoothing = {
      gravity = 40;
      noise_reduction = 0.25;
      monstercat = 1;
    };
  };
}
