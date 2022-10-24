{ lib
, rice
, roboto
, i3lock-color
, writeScriptBin
, font ? {
    package = roboto;
    name = "Roboto";
  }
, palette ? rice.palette.palette { }
, ...
}:
let strPalette = lib.rice.palette.toRGBAHex palette;
in writeScriptBin "lockscreen" ''
  # Using font package ${font.package}
  ${i3lock-color}/bin/i3lock-color \
  --insidever-color="${strPalette.normal.green}" \
  --insidewrong-color="${strPalette.normal.red}" \
  --inside-color="${strPalette.normal.black}" \
  --ringver-color="${strPalette.bright.green}" \
  --ringwrong-color="${strPalette.bright.red}" \
  --ringver-color="${strPalette.bright.green}" \
  --ringwrong-color="${strPalette.bright.red}" \
  --ring-color="${strPalette.bright.blue}" \
  --line-uses-ring \
  --keyhl-color="${strPalette.bright.red}" \
  --bshl-color="${strPalette.bright.red}" \
  --separator-color="${strPalette.normal.black}" \
  --verif-color="${strPalette.normal.green}" \
  --wrong-color="${strPalette.normal.red}" \
  --layout-color="${strPalette.normal.blue}" \
  --date-color="${strPalette.normal.blue}" \
  --time-color="${strPalette.normal.blue}" \
  --blur 10 \
  --clock \
  --indicator \
  --time-str="%H:%M:%S" \
  --date-str="%a %e %b %Y" \
  --verif-text="Verifying..." \
  --wrong-text="Auth Failed" \
  --noinput="No Input" \
  --lock-text="Locking..." \
  --lockfailed="Lock Failed" \
  --time-font="${font.name}" \
  --date-font="${font.name}" \
  --layout-font="${font.name}" \
  --verif-font="${font.name}" \
  --wrong-font="${font.name}" \
  --radius=120 \
  --ring-width=20 \
  --pass-media-keys \
  --pass-screen-keys \
  --pass-volume-keys \
  --nofork
''
