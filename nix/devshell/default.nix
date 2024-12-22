{ inputs, ... }:
{
  perSystem =
    {
      self',
      inputs',
      pkgs,
      system,
      ...
    }:
    let
      nixpkgsSystemUnstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      devToolPackages = with pkgs; [
        cargo-udeps
        coreutils
        llvmPackages.bintools # lld for wasm
        nodejs
        openssl
        openssl.dev
        self'.packages.tuono
        wasm-pack # wasm usage
        yarn
        yarn2nix
      ];

      rustToolchain = (
        inputs'.fenix.packages.combine [
          (inputs'.fenix.packages.stable.withComponents [
            "cargo"
            "clippy"
            "rust-analyzer"
            "rust-src"
            "rustc"
            "rustfmt"
          ])
          inputs'.fenix.packages.targets.wasm32-unknown-unknown.stable.rust-std
        ]
      );
    in
    {
      devShells.default = pkgs.mkShell {
        name = "tuono-dev";

        packages = (
          devToolPackages
          ++ [ rustToolchain ]
        );

        CARGO = "${rustToolchain}/bin/cargo";
        CARGO_TARGET_WASM32_UNKNOWN_UNKNOWN_LINKER = "lld";
        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl ];
        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
      };
    };
}
