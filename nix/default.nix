args@{ lib, ... }:
{
  _class = "flake";

  imports = [
    ./devshell.nix
    ./packages.nix
  ];
}
