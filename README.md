# proton-cachyos (Nix)

[Proton-CachyOS](https://github.com/CachyOS/proton-cachyos) by the
[CachyOS](https://cachyos.org) team is Valve Proton with CachyOS patches. This
flake packages its prebuilt releases as Steam compatibility tools for NixOS, the
same way nixpkgs packages `proton-ge-bin`. It is for anyone who wants
Proton-CachyOS in Steam's Compatibility dropdown from their own configuration,
with no runner-manager app.

There are packages for `x86_64-linux` and `aarch64-linux`. The checks of this
repository build every tool and read the name it gives Steam. None of them
starts Steam or runs a game.

## Install

Add the flake:

```nix
{
  inputs.proton-cachyos = {
    url = "github:Daaboulex/proton-cachyos-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}
```

Then apply the overlay and hand the tool to Steam:

```nix
{
  nixpkgs.overlays = [ inputs.proton-cachyos.overlays.default ];

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-cachyos ];
  };
}
```

Steam then lists it in each game's Compatibility dropdown.

Without the overlay, take the package from the flake itself:

```nix
programs.steam.extraCompatPackages = [
  inputs.proton-cachyos.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

## Which package to take

Every variant upstream publishes is packaged.

| Package | What it is | Systems |
|---|---|---|
| `proton-cachyos` | The build for your own machine: x86_64 on `x86_64-linux`, arm64 on `aarch64-linux`. It is also `packages.default`. | both |
| `proton-cachyos-v3` | The x86-64-v3 build, for CPUs that meet that level, which includes AVX2 | `x86_64-linux` |
| `proton-cachyos-x86_64` | The x86_64 build on either architecture, for an x86 Steam client running under FEX on aarch64 | both |
| `proton-cachyos-x86_64-v3` | The same for the x86-64-v3 build | both |

On `x86_64-linux` the last two are the same packages as the first two.

## Staying on one release line

`pkgs.proton-cachyos` follows upstream's newest release. Each package also
carries channels, so you can stay on one major line instead.

| Channel | What it follows |
|---|---|
| `latest` | Upstream's newest release. The package itself is this channel. |
| `v<major>` | One major line. It follows the newest release of that line while upstream still releases it, and stays on the last one after that. |

```nix
programs.steam.extraCompatPackages = [
  pkgs.proton-cachyos
  pkgs.proton-cachyos-v3.v10
];
```

Steam lists both. The dropdown shows `Proton-CachyOS <major> (<build>, latest)`
for `latest` and `Proton-CachyOS <major> (<build>)` for a line, with `v3` first
in the brackets for that variant. A game keeps the channel you chose for it
through every update.

The releases behind the channels are in [sources.nix](sources.nix), which a
daily updater moves. When upstream opens a new major, the updater keeps the
outgoing line as a channel, so no channel vanishes.

## Known limits

- `proton-cachyos-v3` exists only on `x86_64-linux`, so the example above is for
  that system. On `aarch64-linux` take `proton-cachyos-x86_64-v3`.
- A line has a channel only for the builds upstream published in it. The `v9`
  line has no arm64 build.
- A package works only through `programs.steam.extraCompatPackages`. Its `out`
  output is a stub, and Steam reads the `steamcompattool` output.
- A variant upstream adds later is found by the updater, but it is not offered
  until someone names it in [flake.nix](flake.nix).

## More

- [docs/DESIGN.md](docs/DESIGN.md): why the packages have two outputs, why a
  channel is not a package of its own, the two names each tool gives Steam
- [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md): upstream and how it is tracked,
  the checks, what the updater does with a new variant and a new major
- [SECURITY.md](SECURITY.md): how to report a vulnerability

## License

The packaging is MIT. Proton-CachyOS itself is upstream's license (Valve Proton
BSD-3-Clause lineage plus bundled components); this flake redistributes
nothing. The tarball is fetched from upstream's GitHub releases at build time.
