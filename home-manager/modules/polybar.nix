{ config, pkgs, ... }:
let
  grep = "${pkgs.gnugrep}/bin/grep";
  cut = "${pkgs.coreutils}/bin/cut";
  head = "${pkgs.coreutils}/bin/head";
  pavucontrol = "${pkgs.pavucontrol}/bin/pavucontrol";
  pgrep = "${pkgs.procps}/bin/pgrep";
  pkill = "${pkgs.procps}/bin/pkill";
  playerCtl = "${pkgs.playerctl}/bin/playerctl";
  playerStatus = "${playerCtl} -f '{{emoji(status)}} {{title}} - {{artist}}' metadata | ${head} -c 60";
  # alacritty = "${pkgs.alacritty}/bin/alacritty";
  # btm = "${pkgs.bottom}/bin/btm";
  colors = with pkgs.rice; palette.toARGBHex rec {

    normal = {
      foreground = colorPalette.normal.white;
      background = colorPalette.normal.black;
      underline = colorPalette.normal.blue;
    };

    active = palette.brighten "50%" normal;

    selected = {
      foreground = colorPalette.bright.white;
      background = color.tAlphaRgba (_: 240) colorPalette.dark.blue;
      underline = colorPalette.dark.white;
    };

    alert = colorPalette.bright.red;

    green = colorPalette.normal.green;
    yellow = colorPalette.normal.yellow;
    orange = colorPalette.bright.red;
    red = colorPalette.normal.red;

    transparent = color.transparent;
  };

  commonBar = {
    locale = config.home.language.base;
    monitor = "\${env:MONITOR}";
    width = "100%";
    height = 20;
    radius = 6.0;
    fixed-center = false;
    background = colors.normal.background;
    foreground = colors.normal.foreground;
    line-size = 2;
    line-color = colors.normal.underline;
    padding = {
      left = 0;
      right = 0;
    };
    module.margin = { left = 0; right = 0; };
    separator = " ";
    border = {
      color = colors.transparent;
      left.size = 2;
      righ.sizet = 2;
      top.size = 2;
      bottom.size = 0;
    };
    font = [
      "${pkgs.rice.font.monospace.name}:size=${toString pkgs.rice.font.monospace.size};2"
      "Material Design Icons:size=${toString pkgs.rice.font.monospace.size};2"
      "NotoEmoji Nerd Font Mono:size=${toString pkgs.rice.font.monospace.size};0"
    ];
    wm-restack = "bspwm";
  };

  ramp = [ "▂" "▃" "▄" "▅" "▆" "▇" ];
in
{
  home.packages = with pkgs; [
    pkgs.rice.font.monospace.package
    emojione
    noto-fonts-emoji
    material-design-icons
  ];
  services.polybar = {
    enable = true;
    package = pkgs.polybarFull;
    script =
      ''
        monitor=`polybar -m | ${grep} primary | ${cut} -d":" -f1`
        MONITOR=$monitor polybar primary &
        monitors=(`polybar -m | ${grep} -v primary | ${cut} -d":" -f1`)
        for monitor in "''${monitors[@]}"; do
          MONITOR=$monitor polybar secondary &
        done
      '';

    settings = {
      "settings" = {
        screenchange-reload = false;
      };

      "bar/primary" = commonBar // {
        modules-left = "bspwm";
        # modules-center =
        modules-right = "player pulseaudio temperature cpu memory battery date powermenu";
        enable-ipc = true;
        tray = {
          position = "right";
          padding = 0;
        };
      };

      "bar/secondary" = commonBar // {
        modules-left = "bspwm";
        # modules-center =
        modules-right = "player pulseaudio temperature cpu memory battery date powermenu";
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
          charging = colors.selected // {
            padding = 1;
            text = "<animation-charging> <label-charging>";
          };
          discharging = colors.active // {
            padding = 1;
            text = "<animation-discharging> <label-discharging>";
          };
          full = colors.normal // {
            padding = 1;
            text = " <label-full>";
          };
        };

        label = {
          chargin = "%percentage%%";
          dischargin = "%percentage%%";
          full = "%percentage%%";
        };
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
            focused = colors.selected // common;
            occupied = colors.active // common;
            urgent = colors.active // common // { background = colors.alert; };
            empty = colors.normal // common // { text = "󰧟"; padding = 0; };
          };
      };

      "module/cpu" = {
        type = "internal/cpu";
        format = colors.normal // {
          text = "󰍛 <label>";
          padding = 1;
        };
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
        format = colors.normal // {
          padding = 1;
        };
      };

      "module/memory" = {
        type = "internal/memory";
        format = colors.normal // {
          padding = 1;
          text = "󰍜 <label>";
        };
        interval = 2;
        label = "%percentage_used%%";
        ramp-used = ramp;
      };

      "module/pulseaudio" = {
        bar.volume = {
          empty = {
            font = "2";
            text = "─";
          };
          fill = {
            text = "─";
            font = "2";
          };
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
          indicator = {
            text = "|";
            font = "2";
          };
          width = "10";
        };
        click.right = "${pgrep} pavucontrol && ${pkill} pavucontrol || ${pavucontrol}";
        format = {
          padding = 1;
          muted = colors.active // {
            padding = 1;
          };
          volume = colors.normal // {
            padding = 1;
            text = "<ramp-volume> <label-volume>";
          };
        };
        label.muted = {
          text = "󰖁";
        };
        label.volume = {
          text = "%percentage%%";
        };
        ramp.volume = [ "󰕿" "󰖀" "󰕾" ];
        type = "internal/pulseaudio";
      };

      "module/temperature" = {
        format = colors.normal // {
          padding = 1;
          text = "<ramp> <label>";
          warn = {
            padding = 1;
            text = "<ramp> <label-warn>";
            underline = colors.alert;
          };
        };
        hwmon.path = "/sys/devices/platform/coretemp.0/hwmon/hwmon5/temp1_input";
        label = {
          text = "%temperature-c%";
          warn = "%temperature-c%";
        };
        ramp = {
          text = [ "" "" "" "" "" ];
        };
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
          open = colors.normal // {
            text = " ⏻ ";
          };
          close = colors.normal // {
            text = "Cancel";
          };
          separator = {
            text = "|";
          };
        };
        menu = [
          [
            ({ text = "Logout"; exec = "#powermenu.open.1"; })
            ({ text = "Reboot"; exec = "#powermenu.open.2"; })
            ({ text = "Hibernate"; exec = "#powermenu.open.3"; })
            ({ text = "Power off"; exec = "#powermenu.open.4"; })
          ]
          [
            ({ text = "Logout"; exec = "${pkgs.systemd}/bin/loginctl terminate-session self"; })
          ]
          [
            ({ text = "Reboot"; exec = "${pkgs.systemd}/bin/systemctl reboot"; })
          ]
          [
            ({ text = "Hibernate"; exec = "${pkgs.systemd}/bin/systemctl hibernate"; })
          ]
          [
            ({ text = "Power off"; exec = "${pkgs.systemd}/bin/shutdown now"; })
          ]
        ];
      };

      "module/player" = {
        type = "custom/script";
        format = colors.normal // {
          padding = 1;
        };
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
