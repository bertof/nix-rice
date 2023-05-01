{ lib, color, kitty-themes-src, ... }:
let
  # Theme path to its readable name
  _themePathToThemeName = path:
    let
      file_name = builtins.baseNameOf path;
      theme_name = builtins.head (builtins.match "(.+)\.conf$" file_name);
    in
    theme_name;

  _themeNameToThemePath = name: "${kitty-themes-src}/themes/${name}.conf";
in
rec {
  # List of themes in kitty-themes-src
  themesFilesPaths = lib.filesystem.listFilesRecursive "${kitty-themes-src}/themes";

  themesNames = map _themePathToThemeName themesFilesPaths;

  parseTheme = path:
    let
      file_contents = lib.strings.fileContents path;
      file_lines = lib.strings.splitString "\n" file_contents;
      line_parser = builtins.match " *([A-z0-9_]+) +(#[A-z0-9_]+) *";
      result_filter = r: builtins.isList r && builtins.length r == 2;
      result_mapper = r:
        let
          key = builtins.head r;
          value = color.hexToRgba (lib.lists.last r);
        in
        { "${key}" = value; };
    in
    builtins.foldl' lib.attrsets.recursiveUpdate { } (
      builtins.map result_mapper (
        builtins.filter result_filter (
          builtins.map line_parser file_lines
        )
      )
    );

  getThemeByName = name: parseTheme (_themeNameToThemePath name);
}
