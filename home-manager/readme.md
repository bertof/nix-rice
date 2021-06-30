# Home manager example

This folder contains an example home-manager integration with the nix-rice library.
We are importing a theme and building a palette with it.
Then we apply the palette to a couple of programs and a custom script.

**Note**: this is a small example of integration. To see a complete integration take a look at my [dotfiles](https://gitlab.com/bertof/nix-dotfiles).

## Themes
Themes are just simple dictionaries with named colors in hexadecimal string format. Importing a theme you can override one or more colors for the palette, otherwise the default one is used.
**Bright** and **dim** variation of the colors are derived from the normal ones: remember to override them too if necessary.

## Alacritty

Alacritty is my favourite terminal emulator. To my knowledge it has the widest support for custom colors and configs, thus I modelled the palette data structure to mostly match its one. Of course, you can adapt it to the one used by other terminal emulators matching the correct configuration key.

## Polybar

I use polybar as my status bar. The polybar module uses nix-rice to integrate the pallete to its configuration.
In this case I had to map the palette colors to the custom modules of the bar. It can probably be reduced significantly moving most of the definition to the `commonBar` base definition for all modules, but it's a simple working example.

## lockscreen.sh

The custom package `lockscreen` is a script that extens the screen locker `i3lock-color` with the rice library, adding support for colors and fonts.
A default implementation is defined in the second overlay of the list in `home.nix`. The last overlay overrides its font and pallette configuration with the custom one we defined.
