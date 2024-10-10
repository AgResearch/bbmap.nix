# bbmap.nix

This is a Nix Flake for BBMap, which provides both an installable package and a dev shell.

## Usage

As a devshell:

```
$ nix develop github:AgResearch/bbmap.nix
$ bbmap.sh -V

$ nix develop github:AgResearch/bbmap.nix#v39_10
$ bbmap.sh -V
```

From another flake, e.g. Home Manager:

```
{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;

    bbmap = {
      url = github:AgResearch/bbmap.nix/main;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { nixpkgs, bbmap, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      flakePkgs = {
        bbmap = bbmap.packages.${system};
      };

...

  packages = [
    flakePkgs.bbmap.v39_10
  ];
```
