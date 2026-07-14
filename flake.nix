{
  description = "Build the OS-agnostic objects of the L4T nvdisplay kernel modules (nv-kernel.o, nv-modeset-kernel.o)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      eachSystem = f: nixpkgs.lib.genAttrs systems f;
    in
    {
      packages = eachSystem (
        system:
        let
          crossPkgs = (import nixpkgs { inherit system; }).pkgsCross.aarch64-multiplatform;
        in
        rec {
          nv-kernel-objects = crossPkgs.stdenv.mkDerivation {
            pname = "nv-kernel-objects";
            version = "540.4.0";

            src = self;

            enableParallelBuilding = true;

            makeFlags = [
              "TARGET_ARCH=aarch64"
              "WHOAMI=true"
              "HOSTNAME=nixbld"
              "DATE=true"
            ];

            buildFlags = [
              "src/nvidia/_out/Linux_aarch64/nv-kernel.o"
              "src/nvidia-modeset/_out/Linux_aarch64/nv-modeset-kernel.o"
            ];

            installPhase = ''
              runHook preInstall
              install -Dm644 -t "$out" \
                  src/nvidia/_out/Linux_aarch64/nv-kernel.o \
                  src/nvidia-modeset/_out/Linux_aarch64/nv-modeset-kernel.o
              runHook postInstall
            '';
          };
          default = nv-kernel-objects;
        }
      );
    };
}
