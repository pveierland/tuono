{
  inputs,
  withSystem,
  ...
}:
let
  tuonoCargoWorkspacePath = ../../.;
in
{
  _class = "flake";

  flake.packages.x86_64-linux = withSystem "x86_64-linux" (
    {
      config,
      inputs',
      pkgs,
      ...
    }:
    let
      tuonoRustToolchain = (
        inputs'.fenix.packages.combine [
          (inputs'.fenix.packages.complete.withComponents [
            "cargo"
            "clippy"
            "rust-analyzer"
            "rust-src"
            "rustc"
            "rustfmt"
          ])
        ]
      );

      craneLib = (inputs.crane.mkLib pkgs).overrideToolchain tuonoRustToolchain;

      src = craneLib.cleanCargoSource tuonoCargoWorkspacePath;

      commonArgs = {
        inherit src;
        strictDeps = true;

        pname = "tuono-crates";
        version = "0.0.1";

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl ];
        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";

        RUSTY_V8_ARCHIVE =
          let
            sha256 = "sha256-V2OLaueiuM4UTcJZ6pd7PldvmlZC5e2kabmjrGSNOCY=";
            target = "x86_64-unknown-linux-gnu";
            version = "129.0.0";
          in
          pkgs.fetchurl {
            name = "librusty_v8-${version}";
            url = "https://github.com/denoland/rusty_v8/releases/download/v${version}/librusty_v8_release_${target}.a.gz";
            inherit sha256;
          };

        nativeBuildInputs = [
          pkgs.nixVersions.latest # needed by nil
          pkgs.python3 # needed by v8 for download
        ];
      };

      tuonoCrates = craneLib.buildDepsOnly commonArgs;

      individualCrateArgs = commonArgs // {
        cargoArtifacts = tuonoCrates;
        doCheck = false;
      };

      tuono = craneLib.buildPackage (
        individualCrateArgs
        // {
          cargoExtraArgs = "-p tuono --bin tuono";
          pname = "tuono";
          version = "0.0.1";
        }
      );
    in
    {
      tuono = tuono;
    }
  );
}
