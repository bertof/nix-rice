# nix-rice

Bring ricing to Nix!

## Why

Nix standard library does not have direct support for colors and their hexadecimal representation, commonly used in package configurations. This library tries to solve this by adding:

- Support to common float operations
- Support to color definitions and transformations (RGBA and HSLA)
- Color serialisation and deserialisation as hexadecimal strings
- Color palette definitions and transformations

## How to use it

An example integration to a home-manager configuration is shown inside the [home-manager](./home-manager) folder.
The library is built using only builtin functions and the [standard nix library](https://github.com/NixOS/nixpkgs/tree/master/lib) and can be easily used even in single derivations as an overlay.

```nix
let
  nix-rice = fetchTarball {
    url = "https://github.com/bertof/nix-rice/archive/refs/tags/v0.1.1.tar.gz";
    sha256 = "07pdvdc1z1nl8vm0w689nwrncr0f09c55f7cr7272rs5pbmjdza6";
  };
  nixpkgs = import <nixpkgs> { overlays = [
    (final: prev: { rice = (prev.lib.callPackageWith prev) nix-rice {}; })
  ]; };
in
{

...

}
```

While the library interface is mostly set, it might change in the future (new transformations, palette generation, conversion to specific programs configurations). It is therefore suggested to use a pinned version like in the example above.


## Contributions

Feel free to modify this library as you please: addition and fixes are welcome. Want to include your favourite theme? Add a new transformation? Send a PR.
