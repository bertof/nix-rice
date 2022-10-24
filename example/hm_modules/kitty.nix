{ pkgs, ... }:
let
  strPalette = with pkgs.rice;
    pkgs.lib.rice.palette.toRgbHex rec {
      inherit (colorPalette.primary) foreground background;
      color0 = colorPalette.normal.black;
      color1 = colorPalette.normal.red;
      color2 = colorPalette.normal.green;
      color3 = colorPalette.normal.yellow;
      color4 = colorPalette.normal.blue;
      color5 = colorPalette.normal.magenta;
      color6 = colorPalette.normal.cyan;
      color7 = colorPalette.normal.white;
      color8 = colorPalette.bright.black;
      color9 = colorPalette.bright.red;
      color10 = colorPalette.bright.green;
      color11 = colorPalette.bright.yellow;
      color12 = colorPalette.bright.blue;
      color13 = colorPalette.bright.magenta;
      color14 = colorPalette.bright.cyan;
      color15 = colorPalette.bright.white;
    };
in
{
  programs.kitty = {
    enable = true;
    package = pkgs.unstable.kitty;
    settings = {
      scrollback_lines = 10000;
      enable_audio_bell = false;
      visual_bell_duration = toString 0.1;
      update_check_interval = 0;
      background_opacity = toString pkgs.rice.opacity;
      close_on_child_death = "yes";
      clipboard_control =
        "write-clipboard write-primary read-clipboard read-primary";
      disable_ligatures = "never";
      editor = "kak";
    } // strPalette;
    keybindings = {
      "ctrl+shift+t" = "new_tab_with_cwd";
      "ctrl+shift+enter" = "new_window_with_cwd";
      "ctrl+shift+n" = "new_os_window_with_cwd";
      "ctrl+shift+up" = "previous_window";
      "ctrl+shift+down" = "next_window";
    };
    font = pkgs.rice.font.monospace;
  };
}
