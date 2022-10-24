{ pkgs, lib, ... }:

let
  monitorPages = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
  monitorPagesString = lib.strings.concatStringsSep " " monitorPages;
  strPalette = pkgs.lib.rice.palette.toRGBHex pkgs.rice.colorPalette;
  xrandr = "${pkgs.xorg.xrandr}/bin/xrandr";
  xsetroot = "${pkgs.xorg.xsetroot}/bin/xsetroot";
in
{
  xsession.windowManager.bspwm = {
    enable = true;
    settings = {
      border_width = 1;
      border_radius = 8;
      window_gap = 2;
      split_ratio = 0.5;
      top_padding = 0;
      borderless_monocle = true;
      gapless_monocle = false;
      normal_border_color = strPalette.normal.blue;
      focused_border_color = strPalette.bright.red;
    };
    # monitors = builtins.foldl' (acc: monitor: acc // { ${monitor} = monitorPages; }) { } monitors;
    rules = {
      "*" = { follow = true; };
      "Zathura" = { state = "tiled"; };
    };
    extraConfig = ''
      ${xsetroot} -solid black -cursor_name left_ptr
      autorandr -c

      for monitor in $(${xrandr} --listactivemonitors | cut -d " " -f 6); do
        bspc monitor $monitor -d ${monitorPagesString}
      done

      systemctl --user restart \
        polybar.service \
        update-background.service
    '';
    startupPrograms = [ ];
  };
  services = {
    network-manager-applet.enable = true;
    blueman-applet.enable = true;
  };
  home.packages = with pkgs; [ blueman ];
}
