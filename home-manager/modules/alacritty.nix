{ pkgs, lib, ... }:
let
  strPalette = with pkgs.rice; palette.toRgbHex colorPalette;
in
{
  # Include fonts packages
  home.packages = [ pkgs.rice.font.monospace.package ];
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      scrolling.history = 3000;
      font = {
        normal.family = pkgs.rice.font.monospace.name;
        size = 9.0;
      };
      background_opacity = pkgs.rice.opacity;
      mouse = {
        hide_when_typing = true;
        hints.modifiers = "Control";
      };

      colors = with pkgs.rice; strPalette // {
        selection = {
          text = "CellForeground";
          background = strPalette.dim.blue;
        };
        search = {
          matches = {
            foreground = "CellForeground";
            background = strPalette.dim.cyan;
          };
          bar = {
            foreground = strPalette.dim.cyan;
            background = strPalette.dim.yellow;
          };
        };
      };
    };
  };
}
