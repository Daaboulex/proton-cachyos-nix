# proton-cachyos (Nix)

<!-- BEGIN generated:badges -->
[![CI](https://github.com/Daaboulex/proton-cachyos-nix/actions/workflows/ci.yml/badge.svg)](https://github.com/Daaboulex/proton-cachyos-nix/actions/workflows/ci.yml)
[![NixOS unstable](https://img.shields.io/badge/NixOS-unstable-78C0E8?logo=nixos&logoColor=white)](https://nixos.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)
<!-- END generated:badges -->

Nix flake packaging for [Proton-CachyOS](https://github.com/CachyOS/proton-cachyos) by the [CachyOS](https://cachyos.org) team - Valve Proton with CachyOS patches, packaged as a declarative Steam compatibility tool the same way nixpkgs packages `proton-ge-bin`.

<!-- BEGIN generated:upstream -->
## Upstream

| | |
|---|---|
| **Project** | [CachyOS/proton-cachyos](https://github.com/CachyOS/proton-cachyos) |
| **License** | BSD-3-Clause (Valve Proton lineage) |
| **Tracked** | GitHub releases (`cachyos-*` tags, daily) |

<!-- END generated:upstream -->

## What Is This?

A Nix flake that fetches the prebuilt Proton-CachyOS release tarballs and exposes them as two-output packages (`out` + `steamcompattool`) mirroring the nixpkgs `proton-ge-bin` shape, so they drop straight into `programs.steam.extraCompatPackages` and show up in Steam's Compatibility dropdown - fully declarative, no runner-manager app needed.

Every variant upstream publishes is packaged:

| Attribute | Upstream asset | System |
|---|---|---|
| `proton-cachyos` (`packages.default`) | `x86_64` | `x86_64-linux` |
| `proton-cachyos` (`packages.default`) | `arm64` | `aarch64-linux` |
| `proton-cachyos-v3` (`packages.x86_64_v3`) | `x86_64_v3` (Zen 4/5-class CPU optimized) | `x86_64-linux` |

A new upstream variant (a future `x86_64_v4`, say) is discovered automatically: the daily updater enumerates the release's assets and regenerates the variant set from whatever CachyOS ships, so a new microarchitecture appears - and a dropped one disappears - with no code change.

- **Package integrity** - SRI source hash, verified on every build
- **CI security** - pinned GitHub Actions (full SHA, not tags), minimal permissions, build-gated PRs
- **Upstream trust** - daily automated release detection, hash recomputation, and a verified test build, auto-committed to `main`
- **Stale cleanup** - weekly `flake.lock` refresh (pushed only if it still builds); orphaned update branches older than 30 days are deleted

## Channels

Current pins as of 2026-07-23; the live truth is `sources.nix` (updated daily).

| Channel | Steam identity | Version |
|---|---|---|
| `latest` (`pkgs.proton-cachyos`) | `Proton-CachyOS-latest` | cachyos-11.0-20260702-slr |
| `v11` | `Proton-CachyOS 11.0-20260702` | cachyos-11.0-20260702-slr |
| `v10` | `Proton-CachyOS 10.0-sunset` | cachyos-10.0-sunset-slr |

`latest` rolls with every upstream release; each `v<major>` is a frozen pin.
Both CPU variants expose the same channel set - the `-v3` package
(`pkgs.proton-cachyos-v3`) carries the same identities with a trailing `v3`
(`Proton-CachyOS-latest v3`), so Steam lists the two side by side.

<!-- BEGIN generated:installation -->
## Installation

Add as a flake input:

```nix
{
  inputs.proton-cachyos = {
    url = "github:Daaboulex/proton-cachyos-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then either take the package directly:

```nix
programs.steam.extraCompatPackages = [
  inputs.proton-cachyos.packages.${pkgs.system}.default
];
```

or apply `inputs.proton-cachyos.overlays.default` and use `pkgs.proton-cachyos`.

<!-- END generated:installation -->

## Usage

```nix
programs.steam = {
  enable = true;
  extraCompatPackages = [ pkgs.proton-cachyos ];
};
```

Steam then lists Proton-CachyOS in each game's Compatibility dropdown. The `out` output is intentionally a stub - the tool is consumed through the `steamcompattool` output only, exactly like nixpkgs `proton-ge-bin`.

## License

The packaging is MIT. Proton-CachyOS itself is upstream's license (Valve Proton BSD-3-Clause lineage plus bundled components); this flake redistributes nothing - the tarball is fetched from upstream's GitHub releases at build time.

<!-- BEGIN generated:footer -->
---

*Maintained as part of the [Daaboulex](https://github.com/Daaboulex) NixOS ecosystem.*
<!-- END generated:footer -->
