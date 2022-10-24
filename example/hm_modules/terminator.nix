{ pkgs, ... }:
let
  strPalette = pkgs.lib.rice.palette.toRgbHex rec {
    inherit (pkgs.rice.colorPalette) normal bright dark;
    background = normal.black;
    foreground = normal.white;
  };
  opacity = toString pkgs.rice.opacity;
  font = pkgs.rice.font.monospace;
  colorString = with strPalette;
    normal: bright:
      builtins.concatStringsSep ":" [
        normal.black
        normal.red
        normal.green
        normal.yellow
        normal.blue
        normal.magenta
        normal.cyan
        normal.white
        bright.black
        bright.red
        bright.green
        bright.yellow
        bright.blue
        bright.magenta
        bright.cyan
        bright.white
      ];
in
{
  home.packages = with pkgs; [ terminator ];

  xdg.configFile."terminator/config".text = with strPalette; ''
    [global_config]
      scroll_tabbar = True
      enabled_plugins = ActivityWatch, LaunchpadCodeURLHandler, APTURLHandler, LaunchpadBugURLHandler
      suppress_multiple_term_dialog = True
      always_split_with_profile = True
    [keybindings]
      help = None
    [profiles]
      [[default]]
        visible_bell = True
        background_color = "${background}"
        background_darkness = ${opacity}
        background_type = transparent
        cursor_color = "${foreground}"
        font = ${font.name} weight=450 ${toString font.size}
        foreground_color = "${foreground}"
        show_titlebar = False
        scrollbar_position = hidden
        scrollback_lines = 10000
        palette = "${colorString normal bright}"
        use_system_font = False
      [[presentation]]
        visible_bell = True
        background_color = "${background}"
        cursor_color = "${foreground}"
        font = ${font.name} weight=450 20
        foreground_color = "${foreground}"
        show_titlebar = False
        palette = "${colorString normal bright}"
        use_system_font = False
    [layouts]
      [[default]]
        [[[child1]]]
          parent = window0
          type = Terminal
          profile = default
        [[[window0]]]
          parent = ""
          type = Window
    [plugins]
  '';
}
