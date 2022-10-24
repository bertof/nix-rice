{ pkgs, ... }: {
  services.screen-locker = {
    enable = true;
    lockCmd = "${pkgs.lockscreen}/bin/lockscreen";
    inactiveInterval = 2; # minutes
    xautolock.extraOptions = [ "-secure" "-lockaftersleep" ];
  };
}
