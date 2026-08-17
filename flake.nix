{
  description = "Proton-CachyOS packaged for NixOS - prebuilt Steam compatibility tool, rolling latest plus pinned channels";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    std = {
      url = "github:Daaboulex/nix-packaging-standard?ref=v2.27.0";
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
        let
          assembled = pkgs.callPackage ./default.nix { };
          isArm = pkgs.stdenv.hostPlatform.isAarch64;
          native = if isArm then assembled.channels.arm64 else assembled.channels.x86_64;
          variantPkgs = lib.filterAttrs (
            _: drv: lib.isDerivation drv && lib.elem pkgs.stdenv.hostPlatform.system drv.meta.platforms
          ) assembled;
        in
        {
          packages = variantPkgs // {
            default = if isArm then assembled.proton-cachyos-arm64 else assembled.proton-cachyos;
          };

          checks.compat-tool-shape =
            let
              named = lib.mapAttrsToList (n: drv: {
                inherit n;
                tool = drv.steamcompattool;
                ver = drv.version;
              }) native;
            in
            pkgs.runCommand "proton-cachyos-shape" { } ''
              ${lib.concatMapStringsSep "\n" (c: ''
                echo "checking channel ${c.n} (${c.ver})"
                test -e "${c.tool}/proton"
                test -f "${c.tool}/compatibilitytool.vdf"
                grep -q '"Proton-CachyOS' "${c.tool}/compatibilitytool.vdf"
                if grep -qF "${c.ver}" "${c.tool}/compatibilitytool.vdf"; then
                  echo "versioned identity ${c.ver} leaked into channel ${c.n}'s vdf" >&2
                  exit 1
                fi
              '') named}
              touch "$out"
            '';
        };

      flake.overlays.default =
        final: prev:
        let
          assembled = final.callPackage ./default.nix { };
          nameOf =
            v: "proton-cachyos" + (if v == "x86_64" then "" else "-" + prev.lib.removePrefix "x86_64_" v);
          variants = builtins.attrNames (import ./sources.nix).variants;
        in
        builtins.listToAttrs (
          map (v: {
            name = nameOf v;
            value = assembled.${nameOf v};
          }) variants
        );
    };
}
