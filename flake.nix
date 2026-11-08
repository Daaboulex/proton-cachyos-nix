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
      url = "github:Daaboulex/nix-packaging-standard/release";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.git-hooks.follows = "git-hooks";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    let
      toolsFor =
        pkgs:
        inputs.std.lib.steamCompatTool {
          inherit pkgs;
          attribute = "proton-cachyos";
          brand = "Proton-CachyOS";
          homepage = "https://github.com/CachyOS/proton-cachyos";
          description = "Proton-CachyOS prebuilt Steam Play compatibility tool";
          license = pkgs.lib.licenses.bsd3;
          sources = import ./sources.nix;
          inherit (pkgs.lib.importJSON ./.github/update.json) majorPattern;
          buildOf =
            tag:
            let
              build = pkgs.lib.head (builtins.match "cachyos-[0-9.]+-(.*)-slr" tag);
            in
            if builtins.match "[0-9]{8}" build != null then
              "${pkgs.lib.substring 0 4 build}-${pkgs.lib.substring 4 2 build}-${pkgs.lib.substring 6 2 build}"
            else
              build;
          assetUrl =
            tag: token:
            "https://github.com/CachyOS/proton-cachyos/releases/download/${tag}/proton-${tag}-${token}.tar.xz";
          variantsOf = release: release.variants;
          tokens = {
            x86_64 = {
              system = "x86_64-linux";
              suffix = "";
              qualifier = null;
            };
            x86_64_v3 = {
              system = "x86_64-linux";
              suffix = "-v3";
              qualifier = "v3";
            };
            arm64 = {
              system = "aarch64-linux";
              suffix = "";
              qualifier = null;
            };
          };
        };
      withAlias =
        pkgs: tools:
        tools
        // pkgs.lib.optionalAttrs pkgs.stdenv.hostPlatform.isAarch64 {
          proton-cachyos-arm64 = pkgs.lib.warn "proton-cachyos-arm64 is proton-cachyos on aarch64-linux now; the alias goes with the next release" tools.proton-cachyos;
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      imports = [ inputs.std.flakeModules.base ];

      perSystem =
        { pkgs, ... }:
        let
          cachyos = toolsFor pkgs;
        in
        {
          packages = withAlias pkgs cachyos.tools // {
            default = cachyos.tools.proton-cachyos;
          };
          checks.compat-tool-shape = cachyos.checks.compat-tool-shape;
        };

      flake.overlays.default = final: _prev: withAlias final (toolsFor final).tools;
    };
}
