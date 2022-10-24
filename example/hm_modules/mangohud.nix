{ pkgs, ... }:
let strPalette = pkgs.lib.rice.palette.toRgbShortHex pkgs.rice.colorPalette;
in {
  programs.mangohud = {
    enable = true;
    enableSessionWide = true;
  };
  xdg.configFile."MangoHud/MangoHud.conf".text = ''
    toggle_fps_limit=F1
    legacy_layout=false
    gpu_stats
    gpu_temp
    gpu_text=GPU
    cpu_stats
    cpu_temp
    cpu_color=${strPalette.normal.blue}
    cpu_text=CPU
    io_color=${strPalette.normal.white}
    vram
    vram_color=${strPalette.dark.magenta}
    ram
    ram_color=${strPalette.normal.magenta}
    fps
    engine_color=${strPalette.normal.red}
    gpu_color=${strPalette.normal.green}
    wine_color=${strPalette.normal.yellow}
    frame_timing=1
    frametime_color=${strPalette.normal.green}
    media_player_color=${strPalette.normal.white}
    background_alpha=0.4
    font_size=24
    background_color=020202
    position=top-left
    text_color=ffffff
    round_corners=0
    toggle_hud=Shift_L+F12
    toggle_logging=Shift_L+F2
    upload_log=F5
    output_folder=/home/bertof
    media_player_name=spotify
  '';
}
