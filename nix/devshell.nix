{ inputs, ... }:
{
  perSystem =
    { self'
    , inputs'
    , pkgs
    , system
    , ...
    }:
    let
      tuonoDevTools = with pkgs; [
        cargo-udeps
        coreutils
        nodejs
        pnpm
        yarn
        yarn2nix
      ];

      tuonoRustToolchain = (
        (inputs'.fenix.packages.stable.withComponents [
          "cargo"
          "clippy"
          "rust-analyzer"
          "rust-src"
          "rustc"
          "rustfmt"
        ])
      );
    in
    {
      devShells.default = pkgs.mkShell {
        name = "tuono-dev";

        packages = (
          tuonoDevTools
          ++ [ tuonoRustToolchain ]
        );

        CARGO = "${tuonoRustToolchain}/bin/cargo";
      };
    };
}
