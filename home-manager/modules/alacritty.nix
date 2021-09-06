{ pkgs, lib, ... }:
let
  strPalette = with pkgs.rice; palette.toRgbHex rec {
    inherit (colorPalette) normal bright;
    dim = colorPalette.dark;

    primary = {
      background = normal.black;
      foreground = normal.white;
      dim_foreground = dim.white;
    };
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
        size = pkgs.rice.font.monospace.size;
      };
      background_opacity = pkgs.rice.opacity;
      mouse = {
        # hide_when_typing = true;
        hints.modifiers = "Control";
      };
      # Merge palette with non RGB values
      colors = with pkgs.rice; strPalette // {
        selection.text = "CellForeground";
        search.matches.foreground = "CellForeground";
      };
    };
  };
}
