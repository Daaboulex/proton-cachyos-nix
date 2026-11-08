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

A Nix flake that fetches the prebuilt Proton-CachyOS release tarballs and exposes them as two-output packages (`out` + `steamcompattool`) mirroring the nixpkgs `proton-ge-bin` shape, so they drop straight into `programs.steam.extraCompatPackages` and show up in Steam's Compatibility dropdown - fully declarative, no runner-manager app needed. The packages are built by the fleet standard's `steamCompatTool`, so this flake carries only upstream's facts: the tag, the asset hashes, the brand and the major line.

Every variant upstream publishes is packaged:

| Attribute | Upstream asset | System |
|---|---|---|
| `proton-cachyos` (`packages.default`, `pkgs.proton-cachyos`) | the host's own build: `x86_64` on `x86_64-linux`, `arm64` on `aarch64-linux` | both |
| `proton-cachyos-v3` | `x86_64_v3` (Zen 4/5-class CPU optimized) | `x86_64-linux` |
| `proton-cachyos-x86_64`, `proton-cachyos-x86_64-v3` | the x86_64 tarballs on a host of either architecture, for an x86 Steam client running under FEX on aarch64; on `x86_64-linux` the same derivations as `proton-cachyos` and `proton-cachyos-v3` | both |
| `proton-cachyos-arm64` | `proton-cachyos` on `aarch64-linux`, kept one release for consumers written against the old name; it warns and goes with the next release | `aarch64-linux` |

A new upstream variant (a future `x86_64_v4`, say) is discovered automatically: the daily updater enumerates the release's assets and regenerates the variant set from whatever CachyOS ships; it then needs one entry in `tokens` in `flake.nix` to say which system it runs on and which word the dropdown shows for it.

- **Package integrity** - SRI source hash, verified on every build
- **CI security** - pinned GitHub Actions (full SHA, not tags), minimal permissions, build-gated PRs
- **Upstream trust** - daily automated release detection, hash recomputation, and a verified test build, auto-committed to `main`
- **Stale cleanup** - weekly `flake.lock` refresh (pushed only if it still builds); orphaned update branches older than 30 days are deleted

## Channels

Every channel is a passthru of the tool attribute (`pkgs.proton-cachyos.v10`, `pkgs.proton-cachyos-v3.v9`), never a top-level package. `latest` follows upstream's newest release; each `v<major>` is the last release of a closed line. When upstream opens a new major, the daily updater pins the outgoing release by itself (`majorPattern` in `.github/update.json`), so no channel vanishes and nobody edits a hash by hand.

Each channel's `compatibilitytool.vdf` carries two names. The key, what Steam saves for a game's choice, is the attribute and the channel and never moves, so a choice survives every update and is the same for the arm64 build and the x86_64 payload on one Steam root. The display name, what the dropdown shows, is `Proton-CachyOS <major> (<build>, latest)` for the rolling channel and `Proton-CachyOS <major> (<build>)` for a pin, with `v3` first in the brackets for that variant; a dated build reads as a date, `sunset` stays a word.

Pins as of 2026-11-08; the live truth is `sources.nix` (updated daily).

| Channel | Key Steam saves | Dropdown | Release | Assets |
|---|---|---|---|---|
| `latest` | `proton-cachyos-latest`, `proton-cachyos-v3-latest` | `Proton-CachyOS 11.0 (2026-10-15, latest)`, `Proton-CachyOS 11.0 (v3, 2026-10-15, latest)` | cachyos-11.0-20261015-slr | x86_64, x86_64_v3, arm64 |
| `v10` | `proton-cachyos-v10`, `proton-cachyos-v3-v10` | `Proton-CachyOS 10.0 (sunset)`, `Proton-CachyOS 10.0 (v3, sunset)` | cachyos-10.0-sunset-slr | x86_64, x86_64_v3, arm64 |
| `v9` | `proton-cachyos-v9`, `proton-cachyos-v3-v9` | `Proton-CachyOS 9.0 (2025-04-26)`, `Proton-CachyOS 9.0 (v3, 2025-04-26)` | cachyos-9.0-20250426-slr | x86_64, x86_64_v3 |

The keys replaced the versioned identities of earlier builds (`Proton-CachyOS-latest`, `Proton-CachyOS-latest arm64`, `Proton-CachyOS 10.0-sunset v3`): a game mapped to one of those shows no tool until it is picked again, once.

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
  extraCompatPackages = [
    pkgs.proton-cachyos
    pkgs.proton-cachyos-v3.v10
  ];
};
```

Steam then lists `Proton-CachyOS 11.0 (2026-10-15, latest)` and `Proton-CachyOS 10.0 (v3, sunset)` in each game's Compatibility dropdown. The `out` output is intentionally a stub - the tool is consumed through the `steamcompattool` output only, exactly like nixpkgs `proton-ge-bin`. `checks.compat-tool-shape` builds every channel of every variant and reads each vdf for the key and display formats.

## License

The packaging is MIT. Proton-CachyOS itself is upstream's license (Valve Proton BSD-3-Clause lineage plus bundled components); this flake redistributes nothing - the tarball is fetched from upstream's GitHub releases at build time.

<!-- BEGIN generated:footer -->
<!-- END generated:footer -->
