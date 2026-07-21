{
  description = "Proton-CachyOS packaged for NixOS - prebuilt Steam compatibility tool, every upstream variant";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    std = {
      url = "github:Daaboulex/nix-packaging-standard?ref=v2.12.0";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.git-hooks.follows = "git-hooks";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [ inputs.std.flakeModules.base ];

      perSystem =
        {
          pkgs,
          self',
          lib,
          ...
        }:
        {
          packages = {
            default = pkgs.callPackage ./package.nix {
              variant = if pkgs.stdenv.hostPlatform.isAarch64 then "arm64" else "x86_64";
            };
          }
          // lib.optionalAttrs pkgs.stdenv.hostPlatform.isx86_64 {
            x86_64_v3 = pkgs.callPackage ./package.nix { variant = "x86_64_v3"; };
          };

          checks.compat-tool-shape =
            let
              tools = [
                self'.packages.default.steamcompattool
              ]
              ++ lib.optional (self'.packages ? x86_64_v3) self'.packages.x86_64_v3.steamcompattool;
            in
            pkgs.runCommand "proton-cachyos-shape" { } ''
              for tool in ${lib.concatStringsSep " " (map toString tools)}; do
                test -f "$tool/compatibilitytool.vdf"
                test -e "$tool/proton"
                grep -q '"proton-cachyos' "$tool/compatibilitytool.vdf"
                if grep -qF "${self'.packages.default.version}" "$tool/compatibilitytool.vdf"; then
                  echo "versioned identity leaked into the vdf" >&2
                  exit 1
                fi
              done
              touch "$out"
            '';
        };

      flake.overlays.default = final: _prev: {
        proton-cachyos = inputs.self.packages.${final.system}.default;
        proton-cachyos-v3 =
          inputs.self.packages.${final.system}.x86_64_v3 or (throw "proton-cachyos-v3 is x86_64-linux only");
      };
    };
}
