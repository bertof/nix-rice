{ config, pkgs, lib, ... }:
with lib;
let
  inherit (pkgs.rice) colorPalette opacity;
  grep = "${pkgs.gnugrep}/bin/grep";
  cut = "${pkgs.coreutils}/bin/cut";
  head = "${pkgs.coreutils}/bin/head";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  pgrep = "${pkgs.procps}/bin/pgrep";
  pkill = "${pkgs.procps}/bin/pkill";
  playerCtl = "${pkgs.playerctl}/bin/playerctl";
  playerStatus =
    "${playerCtl} -f '{{emoji(status)}} {{title}} - {{artist}}' metadata | ${head} -c 60";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  shutdown = "${pkgs.systemd}/bin/shutdown";
  logout = pkgs.writeShellScript "logout" ''
    session=`${loginctl} session-status | ${pkgs.coreutils}/bin/head -n 1 | ${pkgs.gawk}/bin/awk '{print $1}'`
    ${loginctl} terminate-session $session
  '';
  colors = with pkgs.lib.rice;
    let alpha = 255 * opacity;
    in
    palette.toARGBHex rec {

      normal = {
        foreground = colorPalette.normal.white;
        background = color.setAlphaRgba alpha colorPalette.normal.black;
        underline = colorPalette.dark.blue;
      };

      active = {
        foreground = colorPalette.bright.white;
        background = color.setAlphaRgba alpha colorPalette.normal.black;
        underline = colorPalette.bright.blue;
      };

      selected = {
        foreground = colorPalette.bright.white;
        background = color.setAlphaRgba alpha
          (color.brighten 10 colorPalette.bright.black);
        underline = colorPalette.bright.red;
      };

      alert = colorPalette.bright.red;

      inherit (colorPalette.normal) green yellow red;
      orange = colorPalette.bright.red;
      inherit (color) transparent;
    };

  commonBar = {
    locale = config.home.language.base;
    monitor = "\${env:MONITOR}";
    width = "100%";
    height = 20;
    radius = 6.0;
    fixed-center = false;
    inherit (colors.normal) background foreground;
    line-size = 2;
    line-color = colors.normal.underline;
    padding = {
      left = 0;
      right = 0;
    };
    module.margin = {
      left = 0;
      right = 0;
    };
    separator = " ";
    border = {
      color = colors.transparent;
      left.size = 2;
      righ.sizet = 2;
      top.size = 2;
      bottom.size = 0;
    };
    font = [
      "${pkgs.rice.font.monospace.name}:size=${
        toString pkgs.rice.font.monospace.size
      };2"
      # "Font Awesome 6 Free:size=14;0"
      # "Noto Color Emoji:size=2;2"
      "Noto Sans Symbols2:size=${toString pkgs.rice.font.monospace.size};2"
      # "Material Design Icons:size=${toString pkgs.rice.font.monospace.size};2"
      # "EmojiOne Color:size=${toString pkgs.rice.font.monospace.size};0"
      "Noto Sans CJK JP:size=${toString pkgs.rice.font.monospace.size};0"
      "Noto Sans CJK KR:size=${toString pkgs.rice.font.monospace.size};0"
      "Noto Sans CJK CN:size=${toString pkgs.rice.font.monospace.size};0"
      "Noto Sans CJK HK:size=${toString pkgs.rice.font.monospace.size};0"
    ];
    wm-restack = "bspwm";
  };

  ramp = [ "▂" "▃" "▄" "▅" "▆" "▇" ];
in
{
  home.packages = with pkgs; [
    pkgs.rice.font.monospace.package
    # emojione
    # noto-fonts-emoji
    noto-fonts
    # material-design-icons
    # font-awesome
    noto-fonts-cjk-sans
  ];
  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    script = ''
      monitor=`polybar -m | ${grep} primary | ${cut} -d":" -f1`
      MONITOR=$monitor polybar primary &
      monitors=(`polybar -m | ${grep} -v primary | ${cut} -d":" -f1`)
      for monitor in "''${monitors[@]}"; do
        MONITOR=$monitor polybar secondary &
      done
    '';

    settings = {
      "settings" = { screenchange-reload = false; };

      "bar/primary" = recursiveUpdate commonBar {
        modules-left = "bspwm";
        # modules-center =
        modules-right =
          "player pulseaudio temperature cpu memory battery date powermenu";
        enable-ipc = true;
        tray = {
          position = "right";
          padding = 0;
        };
      };

      "bar/secondary" = recursiveUpdate commonBar {
        modules-left = "bspwm";
        # modules-center =
        modules-right =
          "player pulseaudio temperature cpu memory battery date powermenu";
        enable-ipc = true;
      };

      "module/battery" = {
        type = "internal/battery";

        adapter = "AC";
        battery = "BAT0";
        full.at = 98;

        animation = {
          charging = {
            text = [ "" "" "" "" "" "" "" "" "" "" ];
            framerate = "750";
          };
          discharging = {
            text = [ "" "" "" "" "" "" "" "" "" "" ];
            framerate = "750";
          };
        };

        format = {
          charging = recursiveUpdate colors.selected {
            text = "<animation-charging> <label-charging>";
          };
          discharging = recursiveUpdate colors.active {
            text = "<animation-discharging> <label-discharging>";
          };
          full = recursiveUpdate colors.normal { text = " <label-full>"; };
        };

        label.text = "%percentage%%";
        #   = {
        #   chargin = "%percentage%%";
        #   dischargin = "%percentage%%";
        #   full = "%percentage%%";
        # };
      };

      "module/bspwm" = {
        type = "internal/bspwm";
        format = "<label-state>";

        label =
          let
            common = {
              padding = 1;
              separator = " ";
              text = "%name%";
            };
          in
          {
            focused = recursiveUpdate colors.selected common;
            occupied = recursiveUpdate colors.active common;
            urgent = recursiveUpdate (recursiveUpdate colors.active common) {
              background = colors.alert;
            };
            empty = recursiveUpdate (recursiveUpdate colors.normal common) {
              text = "󰧟";
              padding = 0;
            };
          };
      };

      "module/cpu" = {
        type = "internal/cpu";
        format = recursiveUpdate colors.normal { text = " <label>"; };
        interval = 2;
        label = "%percentage-sum%%";
        ramp-load = ramp;
      };

      "module/date" = {
        type = "internal/date";
        date = {
          alt = "%Y-%m-%d";
          text = "%a %d/%m/%y";
        };
        interval = "1";
        label = "%date% %time%";
        time = {
          alt = "%H:%M:%S";
          text = "%H:%M";
        };
        format = colors.normal;
      };

      "module/memory" = {
        type = "internal/memory";
        format = recursiveUpdate colors.normal { text = " <label>"; };
        interval = 2;
        label = "%percentage_used%%";
        ramp-used = ramp;
      };

      "module/pulseaudio" = {
        interval = 2;
        bar.volume = {
          empty = { text = "─"; };
          fill = { text = "─"; };
          indicator = { text = "|"; };
          width = "10";
          foreground = [
            colors.green
            colors.green
            colors.green
            colors.green
            colors.green
            colors.yellow
            colors.orange
            colors.red
          ];
        };
        click.right =
          "${pgrep} pavucontrol && ${pkill} pavucontrol || ${pavucontrol}";
        format = {
          padding = 1;
          muted = colors.active;
          volume = recursiveUpdate colors.normal {
            text = "<ramp-volume> <label-volume>";
          };
        };
        label.muted.text = "婢 muted";
        label.volume.text = "%percentage%%";
        ramp.volume = [ "奄" "奔" "墳" ];
        type = "internal/pulseaudio";
      };

      "module/temperature" = {
        format = recursiveUpdate colors.normal {
          text = "<ramp> <label>";
          warn = {
            text = "<ramp> <label-warn>";
            underline = colors.alert;
          };
        };
        hwmon.path =
          "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
        label = {
          text = "%temperature-c%";
          warn = "%temperature-c%";
        };
        ramp.text = [ "" "" "" "" "" ];
        thermal.zone = "0";
        type = "internal/temperature";
        warn.temperature = "90";
      };

      "module/powermenu" = {
        type = "custom/menu";
        expand.right = true;
        format = {
          spacing = 1;
          suffix = " ";
        };
        label = {
          open = recursiveUpdate colors.normal { text = " ⏻ "; };
          close = recursiveUpdate colors.normal { text = "Cancel"; };
          separator = { text = "|"; };
        };
        menu = [
          [
            {
              text = "Logout";
              exec = "#powermenu.open.1";
            }
            {
              text = "Reboot";
              exec = "#powermenu.open.2";
            }
            {
              text = "Hibernate";
              exec = "#powermenu.open.3";
            }
            {
              text = "Power off";
              exec = "#powermenu.open.4";
            }
          ]
          [
            {
              text = "Logout";
              exec = logout;
            }
          ]
          [
            {
              text = "Reboot";
              exec = "${systemctl} reboot";
            }
          ]
          [
            {
              text = "Hibernate";
              exec = "${systemctl} hibernate";
            }
          ]
          [
            {
              text = "Power off";
              exec = "${shutdown} now";
            }
          ]
        ];
      };

      "module/player" = {
        type = "custom/script";
        format = recursiveUpdate colors.normal { padding = 0; };
        exec = playerStatus;
        click.left = "${playerCtl} play-pause";
        scroll = {
          up = "${playerCtl} previous";
          down = "${playerCtl} next";
        };
        interval = 1;
      };
    };
  };
}
