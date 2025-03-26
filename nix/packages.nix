{ inputs
, lib
, withSystem
, ...
}:
let
  tuonoCargoWorkspacePath = ./..;
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
      tuonoRustToolchain = inputs'.fenix.packages.complete.withComponents [
        "cargo"
        "rustc"
      ];

      tuonoCraneLib = (inputs.crane.mkLib pkgs).overrideToolchain tuonoRustToolchain;

      tuonoCargoArtifactsArgs = {
        pname = "tuono-cargo-artifacts";
        version = "0.0.0";

        nativeBuildInputs = [
          pkgs.makeWrapper
          pkgs.python3 # needed by v8 for download
        ];

        src = tuonoCraneLib.cleanCargoSource tuonoCargoWorkspacePath;
        strictDeps = true;

        OPENSSL_DIR = "${pkgs.openssl.dev}";
        OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
        OPENSSL_NO_VENDOR = "1";

        RUSTY_V8_ARCHIVE =
          let
            sha256 = "sha256-5q3VDgBgZlwNGN89XvHsez8O1cNtpzwDXrjFcfM4avU=";
            target = "x86_64-unknown-linux-gnu";
            version = "134.1.0";
          in
          pkgs.fetchurl {
            name = "librusty_v8-${version}";
            url = "https://github.com/denoland/rusty_v8/releases/download/v${version}/librusty_v8_release_${target}.a.gz";
            inherit sha256;
          };
      };

      tuonoCargoArtifacts = tuonoCraneLib.buildDepsOnly tuonoCargoArtifactsArgs;

      tuono = tuonoCraneLib.buildPackage (
        tuonoCargoArtifactsArgs // {
          pname = "tuono";
          version = "0.0.0";
          doCheck = false;

          cargoArtifacts = tuonoCargoArtifacts;
          cargoExtraArgs = "-p tuono --bin tuono";

          postInstall = ''
            wrapProgram $out/bin/tuono \
              --set OPENSSL_DIR ${pkgs.openssl.dev} \
              --set OPENSSL_LIB_DIR ${pkgs.openssl.out}/lib \
              --set OPENSSL_NO_VENDOR 1 \
              --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ pkgs.openssl ]}
          '';
        }
      );
    in
    {
      default = tuono;
      tuono = tuono;
    }
  );
}
