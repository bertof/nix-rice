{ pkgs, ... }:
let strPalette = pkgs.lib.rice.palette.toRgbHex pkgs.rice.colorPalette;
in {
  programs.zathura = {
    enable = true;
    options = {
      completion-bg = strPalette.bright.black;
      default-bg = strPalette.normal.black;
      font = "${pkgs.rice.font.normal.name} 10";
      inputbar-bg = strPalette.bright.black;
      inputbar-fg = strPalette.normal.cyan;
      page-padding = 10;
      recolor-lightcolor = strPalette.normal.black;
      recolor-darkcolor = strPalette.dark.white;
      statusbar-bg = strPalette.bright.black;
      selection-clipboard = "clipboard";
    };
  };
}
