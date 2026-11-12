# Design

Why the packaging is built the way it is. The [README](../README.md) says how
to use it.

## Prebuilt releases in the nixpkgs shape

This flake fetches the prebuilt Proton-CachyOS release tarballs and exposes
them as two-output packages, `out` and `steamcompattool`, mirroring the nixpkgs
`proton-ge-bin` shape. So they drop straight into
`programs.steam.extraCompatPackages` and show up in Steam's Compatibility
dropdown, fully declarative, with no runner-manager app needed.

The `out` output is intentionally a stub. The tool is consumed through the
`steamcompattool` output only, exactly like nixpkgs `proton-ge-bin`.

This flake redistributes nothing. Each tarball is fetched from upstream's
GitHub releases at build time.

## Only upstream's facts live here

The packages are built by the fleet standard's `steamCompatTool`, reached as
`inputs.std.lib.steamCompatTool` in [flake.nix](../flake.nix). So this flake
carries only upstream's facts: the tag, the asset hashes, the brand and the
major line.

## The x86_64 packages on both architectures

`proton-cachyos-x86_64` and `proton-cachyos-x86_64-v3` are the x86_64 tarballs
on a host of either architecture. They are there for an x86 Steam client
running under FEX on aarch64. On `x86_64-linux` they are the same derivations
as `proton-cachyos` and `proton-cachyos-v3`.

## A channel is a passthru, never a package

Every channel is a passthru of the tool attribute, `pkgs.proton-cachyos.v10` or
`pkgs.proton-cachyos-v3.v9`, never a top-level package.

`latest` follows upstream's newest release. Each `v<major>` is a line. The
rolling line's channel follows its newest release and shows as a pin. A closed
line's channel is its last release.

## The two names in each vdf

Each channel's `compatibilitytool.vdf` carries two names.

The key is what Steam saves for a game's choice. It is the attribute and the
channel, `proton-cachyos-latest` or `proton-cachyos-v3-v10`, and it never
moves. So a choice survives every update, and it is the same for the arm64
build and the x86_64 payload on one Steam root.

The display name is what the dropdown shows. It is
`Proton-CachyOS <major> (<build>, latest)` for the rolling channel and
`Proton-CachyOS <major> (<build>)` for a pin, with `v3` first in the brackets
for that variant.

A dated build reads as a date, and `sunset` stays a word. In the plain x86_64
variant the pin `cachyos-9.0-20250426-slr` shows as
`Proton-CachyOS 9.0 (2025-04-26)`, and `cachyos-10.0-sunset-slr` shows as
`Proton-CachyOS 10.0 (sunset)`. `buildOf` in [flake.nix](../flake.nix) does
that.
