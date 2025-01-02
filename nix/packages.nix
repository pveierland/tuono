{ inputs
, lib
, withSystem
, ...
}:
let
  tuonoCargoWorkspacePath = ../.;
in
{
  _class = "flake";

  flake.packages.x86_64-linux = withSystem "x86_64-linux" (
    { config
    , inputs'
    , pkgs
    , ...
    }:
    let
      tuonoRustToolchain = (
        inputs'.fenix.packages.combine [
          (inputs'.fenix.packages.complete.withComponents [
            "cargo"
            "rustc"
          ])
        ]
      );

      tuonoCraneLib = (inputs.crane.mkLib pkgs).overrideToolchain tuonoRustToolchain;

      tuonoCargoArtifactsArgs = {
        pname = "tuono-cargo-artifacts";
        version = "0.0.0";

        nativeBuildInputs = [
          pkgs.python3 # needed by v8 for download
        ];

        src = tuonoCraneLib.cleanCargoSource tuonoCargoWorkspacePath;
        strictDeps = true;

        LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.openssl ];
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
      };

      tuonoCargoArtifacts = tuonoCraneLib.buildDepsOnly tuonoCargoArtifactsArgs;

      tuonoCrateArgs = tuonoCargoArtifactsArgs // {
        cargoArtifacts = tuonoCargoArtifacts;
        doCheck = false;
        version = "0.0.0";
      };

      tuono = tuonoCraneLib.buildPackage (
        tuonoCrateArgs
        // {
          cargoExtraArgs = "-p tuono --bin tuono";
          pname = "tuono";
        }
      );
    in
    {
      default = tuono;
      tuono = tuono;
    }
  );
}
