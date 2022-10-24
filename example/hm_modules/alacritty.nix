{ pkgs, ... }:
let
  strPalette = with pkgs.rice;
    pkgs.lib.rice.palette.toRgbHex rec {
      inherit (colorPalette) normal bright primary;
      dim = colorPalette.dark;

      cursor = {
        cursor = normal.white;
        text = normal.black;
      };
      vi_mode_cursor = {
        cursor = normal.white;
        text = normal.black;
      };
      selection.background = dim.blue;
      search = {
        matches.background = dim.cyan;
        bar = {
          foreground = dim.cyan;
          background = dim.yellow;
        };
      };
    };
in
{
  # Include fonts packages
  home.packages = [ pkgs.rice.font.monospace.package ];
  programs.alacritty = {
    enable = true;
    settings = {
      # env.TERM = "xterm-256color";
      env.TERM = "alacritty";
      scrolling.history = 3000;
      font = {
        normal.family = pkgs.rice.font.monospace.name;
        size = pkgs.rice.font.monospace.size / 1.5; # Font size is broken
      };
      window.opacity = pkgs.rice.opacity;
      mouse = {
        # hide_when_typing = true;
        hints.modifiers = "Control";
      };
      colors = with pkgs.rice;
        strPalette // {
          selection.text = "CellForeground";
          search.matches.foreground = "CellForeground";
        };
    };
  };
}
