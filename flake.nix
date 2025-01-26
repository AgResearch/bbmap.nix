{
  description = "Flake for BBMap, a short-read aligner for DNA and RNA-seq data";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          # extend as required
          default_version = "v39_10";

          available_versions = {
            "v39_10" = {
              version = "39.10";
              hash = "sha256-mWr/BXZbpeZFR/ijTFbaOWznsY25b/5/EHby0vScYUg=";
            };
          };

          bbmap = ver:
            with pkgs;
            with available_versions.${ver};
            stdenv.mkDerivation rec {
              pname = "BBMap";
              arch = builtins.head (lib.strings.splitString "-" system);

              inherit version;
              inherit hash;

              src = fetchurl {
                url = "https://downloads.sourceforge.net/project/${lib.toLower pname}/${pname}_${version}.tar.gz";
                inherit hash;
              };

              nativeBuildInputs = [ makeWrapper ];

              buildInputs = [
                gawk
                openjdk
              ];

              installPhase = ''
                mkdir -p $out/bin
                mv *.sh $out/bin
                mv config $out/bin
                mv current $out/bin
                mv docs $out/bin
                mv jni $out/bin
                mv pipelines $out/bin
                mv resources $out/bin
                rm -rf *
              '';

              postFixup = ''
                # wrap all the scripts except calcmem.sh, which gets sourced, and would break if wrapped
                for prog in $out/bin/*.sh; do
                  test "$prog" == "$out/bin/calcmem.sh" || {
                    wrapProgram "$prog" \
                      --set PATH $out/bin:${lib.makeBinPath [
                        coreutils
                        gawk
                        openjdk
                      ]}
                  }
                done
              '';

              meta = {
                homepage = "https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbmap-guide/";
                description = "short-read aligner for DNA and RNA-seq data";
                platforms = lib.platforms.all;
                license = lib.licenses.bsd3;
              };
            };

        in
        with pkgs;
        {
          devShells = {
            default = mkShell {
              buildInputs = [ (bbmap default_version) ];
            };
          } // builtins.mapAttrs
            (ver: _:
              mkShell {
                buildInputs = [ (bbmap ver) ];
              }
            )
            available_versions;

          packages = {
            default = bbmap default_version;
          } // builtins.mapAttrs (ver: _: bbmap ver) available_versions;
        }
      );
}
