args@{ lib, ... }:
{
  _class = "flake";

  imports = [
    ./devshell
    ./pkgs
  ];
}
