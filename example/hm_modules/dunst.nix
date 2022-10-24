{ pkgs, ... }:
let palette = pkgs.lib.rice.palette.toRGBHex pkgs.rice.colorPalette;
in {
  home.packages = with pkgs; [ dunst rice.font.normal.package ];
  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.qogir-icon-theme;
      name = "Qogir-dark";
    };
    settings = {
      global = {
        monitor = 0;
        follow = "mouse";
        geometry = "300x6-20+50";
        indicate_hidden = "yes";
        shrink = "yes";
        transparency = 10;
        notification_height = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        frame_width = 2;
        frame_color = palette.normal.black;
        separator_color = palette.normal.blue;
        sort = "yes";
        idle_threshold = 120;

        font = "${pkgs.rice.font.normal.name} 10";
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        show_age_threshold = 60;
        word_wrap = "yes";
        ellipsize = "middle";
        ignore_newline = "no";
        stack_duplicates = "true";
        hide_duplicate_count = "false";
        show_indicators = "yes";
        icon_position = "off";
        max_icon_size = 32;
        sticky_history = "yes";
        history_length = 20;
        dmenu = "dmenu -p dunst:";
        # browser = "google-chrome-stable";
        browser = "firefox";
        always_run_script = "true";
        title = "Dunst";
        class = "Dunst";
        startup_notification = "false";
        verbosity = "mesg";
        corner_radius = 0;
        force_xinerama = "false";
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action";
        mouse_right_click = "close_all";
      };
      urgency_low = {
        background = palette.normal.black;
        foreground = palette.normal.white;
        timeout = 10;
      };
      urgency_normal = {
        background = palette.normal.black;
        foreground = palette.normal.white;
        timeout = 10;
      };
      urgency_critical = {
        background = palette.normal.black;
        foreground = palette.normal.white;
        frame_color = palette.bright.red;
        timeout = 0;
      };
      shortcuts = {
        close = "ctrl+space";
        close_all = "ctrl+shift+space";
        history = "ctrl+backslash";
        context = "ctrl+shift+period";
      };
    };
  };
}
