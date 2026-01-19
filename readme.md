# nix-rice

**Bring ricing to Nix!**

Nix-rice is a Nix library that simplifies the configuration of your system's visual aspects by providing powerful functions for color transformation, configuration management, and clean handling of color palettes. Compatible with both traditional and flakes-based Nix setups, it offers a unified overlay for managing color schemes across your packages and applications.

## Table of Contents

- [Why nix-rice?](#why-nix-rice)
- [Installation](#installation)
- [Usage](#usage)
- [API Overview](#api-overview)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)

## Why nix-rice?

The Nix standard library lacks built-in support for colors and their hexadecimal representations, which are essential for theming package configurations. Nix-rice addresses this gap by providing:

- Color definitions and transformations (RGBA and HSLA color spaces)
- Color serialization and deserialization to/from hexadecimal strings
- Color palette definitions and transformations
- A large collection of ready-to-use themes based on [kovidgoyal's kitty-themes](https://github.com/kovidgoyal/kitty-themes)

## Installation

Nix-rice supports both the standard derivation input system and the new flake system.


### Nix-rice with default import system

1. Fetch the `nix-rice` using `fetchGit` as `nix-rice`
2. Either load the library:
  a. Import the library file using `nix-rice-lib = import (nix-rice + "/lib.nix")`;
  b. Access the library using using `nix-rice-lib`
3. Or load the overlay:
  a. Import the overlay file using `nix-rice-overlay = import (nix-rice + "/overlay.nix")`;
  b. Apply the overlay when importing `nixpkgs`
  c. Access the library using `nixpkgs.lib.nix-rice`

Example:

```nix
let
  nix-rice = builtins.fetchGit {
    url = "https://github.com/bertof/nix-rice.git";
    ref = "refs/tags/v0.3.7";
  };
  nix-rice-overlay = import (nix-rice + "/overlay.nix");
  pkgs = import <nixpkgs> { overlays = [ nix-rice-overlay ];};
in
{
  # < YOUR CONFIGURATION HERE >
}
```

### Nix-rice with flakes

1. Add `nix-rice` to your inputs;
2. Access the library, either through `nix-rice.lib` or, applying the standard overlay, through `pkgs.lib.nix-rice`.

Example:

```nix
{
  inputs = {
    # < OTHER INPUTS HERE >
    nixpkgs.url = "github:NixOS/nixpkgs/release-22.11";
    flake-utils.url = "github:numtide/flake-utils";
    nix-rice = { url = "github:bertof/nix-rice"; };
  };

  outputs = { self, nixpkgs, nix-rice }:
  let
    overlays = [ nix-rice.overlays.default ];
  in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit overlays; };
      in
      {
        # < YOUR CONFIGURATION HERE >
      });
}

```

## How to use it

Nix-rice provides a the library module with the following submodules:

- `op`: extends the standard library with utility functions for managing numbers;
- `float`: extends the standard library with float-specific functions, like integer division, module operator, ceil, floor and float conversion;
- `hex`: contains a hexadecimal parser and serializer for integers
- `color`: contains the logic for color parsing, transformation, serialization and conversion;
- `palette`: contains the logic for color palette parsing, transformation, serialization and conversion;
- `kitty-themes`: contains a [Kitty terminal](https://github.com/kovidgoyal/kitty) configuration parser and theme loader.

The general workflow to use Nix-rice is the following:

1. **Define a color palette**: you can load any of the themes in [Kitty themes](https://github.com/kovidgoyal/kitty-themes/tree/4d309e984b81dd120d7a697abe4f817da6f3cfe5/themes) or create one from scratch:
  ```nix
  with pkgs.lib.nix-rice;
   colorPalette = palette.tPalette color.hexToRgba {
     red = "#FF0000FF";
     green = "#00FF00FF";
     blue = "#0000FFFF";
     # < ANY OTHER COLOR HERE >
   };
  ```
  `color.hexToRgba` is applied recursively, so you can have nested or lazy evaluated colors, i.e. you can load your palette from a JSON file and parse it with Nix-rice.

  **TIP**: it's useful to store your parsed palette in your configuration as an overlay, so that you can load it from any package and more uniformly apply transformations:
  ```nix
  self: super: with super.lib.nix-rice; let theme = kitty-themes.getThemeByName "Catppuccin-Mocha"; in {
    rice.colorPalette = rec {
      normal = palette.defaultPalette // {
        black = theme.color0;
        red = theme.color1;
        green = theme.color2;
        yellow = theme.color3;
        blue = theme.color4;
        magenta = theme.color5;
        cyan = theme.color6;
        white = theme.color7;
      };
      bright = palette.brighten 10 normal // {
        black = theme.color8;
        red = theme.color9;
        green = theme.color10;
        yellow = theme.color11;
        blue = theme.color12;
        magenta = theme.color13;
        cyan = theme.color14;
        white = theme.color15;
      };
    } // theme;
  }
  ```

2. **Transform**: transform and adapt your palette.
   Nix-rice provides bidirectional conversion for RGBA and HSLA.
   For ease of use, Nix-rice also provides `brighten` and `darken` functions.
   Future plans include the extension of transformation functions with several mixing modes.

3. **Translate**: convert your palette to the most appropriate serialization.
   Nix-rice provides bidirectional conversion for upper case and lower case versions of RGB, RGBA, ARGB, both with and without the initial `#`.
   Convert the palette to its serialized version and use it in your configurations.

### Home-Manager

This is example shows part of configuration for BSPWM through `home-manager`:
```nix
{ pkgs, lib, ... }:
  with pkgs.lib.nix-rice;
  let strPalette = palette.toRGBHex pkgs.rice.colorPalette;
  in {
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
    };
  }
```

This is an example on the integration of Nix-rice with Alacritty through `home-manager`:
 ```nix
{ pkgs, ... }:
  let strPalette =
    with pkgs.rice;
    pkgs.lib.nix-rice.palette.toRgbHex rec {
      inherit (colorPalette) normal bright primary;
      dim = colorPalette.dark;
      cursor = { cursor = normal.white; text = normal.black; };
      vi_mode_cursor = { cursor = normal.white; text = normal.black; };
      selection.background = dim.blue;
      search = {
        matches.background = dim.cyan;
        bar = { foreground = dim.cyan; background = dim.yellow; };
      };
    };
  in {
    # Include fonts packages
    home.packages = [ pkgs.rice.font.monospace.package ];
    programs.alacritty = {
      enable = true;
      settings = {
        # env.TERM = "xterm-256color";
        env.TERM = "alacritty";
        scrolling.history = 3000;
        font = {
          normal.family = pkgs.rice.font.monospace.name;
          size = pkgs.rice.font.monospace.size / 1.5; # Font size is broken
        };
        window.opacity = pkgs.rice.opacity;
        mouse = {
          # hide_when_typing = true;
          hints.modifiers = "Control";
        };
        colors = with pkgs.rice; strPalette // {
          selection.text = "CellForeground";
          search.matches.foreground = "CellForeground";
        };
      };
    };
  }
```

## API Overview

Nix-rice provides several submodules accessible via `lib.nix-rice`:

- **`op`**: Utility functions for numbers (abs, clamp, inRange, etc.)
- **`float`**: Float-specific operations (toFloat, floor, ceil, round, div', mod')
- **`hex`**: Hexadecimal parsing and serialization
- **`color`**: Color manipulation (RGBA/HSLA constructors, conversions, transformations like brighten/darken, serialization to hex)
- **`palette`**: Palette management (apply transformations to color sets, serialization)
- **`kitty-themes`**: Theme loading from Kitty themes repository

For detailed API documentation, refer to the source files in the repository.

## Examples

This is a complete overlay example saving the theme in the `rice` derivation.
This also includes font configuration and fail safe colors definitions using `palette.defaultPalette`.

```nix
self: super:
with super.lib.nix-rice;
let theme = kitty-themes.getThemeByName "Catppuccin-Mocha";
in {
  rice = {
    colorPalette = rec {
      normal = palette.defaultPalette // {
        black = theme.color0;
        red = theme.color1;
        green = theme.color2;
        yellow = theme.color3;
        blue = theme.color4;
        magenta = theme.color5;
        cyan = theme.color6;
        white = theme.color7;
      };
      bright = palette.brighten 10 normal // {
        black = theme.color8;
        red = theme.color9;
        green = theme.color10;
        yellow = theme.color11;
        blue = theme.color12;
        magenta = theme.color13;
        cyan = theme.color14;
        white = theme.color15;
      };
      dark = palette.darken 10 normal;
      primary = {
        inherit (theme) background foreground;
        bright_foreground = color.brighten 10 theme.foreground;
        dim_foreground = color.darken 10 theme.foreground;
      };
    } // theme;
    font = {
      normal = {
        name = "Cantarell";
        package = self.cantarell-fonts;
        size = 10;
      };
      monospace = {
        name = "FiraCode Nerd Font Mono";
        package = self.nerdfonts.override { fonts = [ "FiraCode" ]; };
        size = 10;
      };
    };
    opacity = 0.95;
  };
}
```

## Notes

While the library interface is mostly stable, it may evolve in the future with new transformations, palette generation features, or program-specific configuration helpers. It is recommended to pin to a specific version, as shown in the examples above.


## Contributing

Feel free to modify this library as you please: additions and fixes are welcome. Do you want to include your favorite theme? Add a new transformation? Send a PR.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
