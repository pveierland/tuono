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
        openssl
        openssl.dev
        self'.packages.tuono
        yarn
        yarn2nix
      ];

      tuonoRustToolchain = (
        inputs'.fenix.packages.combine [
          (inputs'.fenix.packages.stable.withComponents [
            "cargo"
            "clippy"
            "rust-analyzer"
            "rust-src"
            "rustc"
            "rustfmt"
          ])
        ]
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
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl ];
        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      };
    };
}
