# Development

## Upstream

| What | Value |
|---|---|
| Project | [CachyOS/proton-cachyos](https://github.com/CachyOS/proton-cachyos) |
| License | BSD-3-Clause (Valve Proton lineage) |
| Tracked | GitHub releases (`cachyos-*` tags, daily) |

The nixpkgs input follows `nixos-unstable`.

## Checks

```bash
nix flake check
```

`checks.compat-tool-shape` builds every channel of every tool the host system
offers and reads each `compatibilitytool.vdf` for the key and display formats.
It refuses a tool with no `proton` entry point or no `toolmanifest.vdf`, a
pinned channel that shows `latest`, an architecture or build-type word in
either name, and one key that names two tools the same client would list.

`checks.overlay-applies` compares the tools `overlays.default` yields with the
flake's own packages, channel by channel, and fails when one differs.

Both come from the standard's `steamCompatTool`. The lint hooks, the formatter
and the dev shell come from the standard's base module, imported as
`inputs.std.flakeModules.base` in [flake.nix](../flake.nix).

## Workflows

| File | What it calls | When |
|---|---|---|
| `.github/workflows/ci.yml` | the standard's `package-ci.yml` | a push to `main` or `master`, a pull request |
| `.github/workflows/update.yml` | the standard's `package-update.yml` | daily, unless the repository variable `UPDATE_CADENCE` says otherwise |
| `.github/workflows/maintenance.yml` | the standard's `package-maintenance.yml` | weekly, unless the repository variable `MAINTENANCE_CADENCE` says otherwise |

Each can also be started by hand.

## Updating

[sources.nix](../sources.nix) holds the rolling release, the pinned releases
and the assets of each. The daily updater moves it, with its settings in
[.github/update.json](../.github/update.json). Nobody edits a hash by hand.

### A new variant

A new upstream variant (a future `x86_64_v4`, say) is discovered automatically.
The daily updater enumerates the release's assets and regenerates the variant
set from whatever CachyOS ships.

The variant then needs one entry in `tokens` in [flake.nix](../flake.nix). The
entry says which system it runs on (`system`), what the attribute name ends in
(`suffix`) and which word the dropdown shows for it (`qualifier`).

### A new major

When upstream opens a new major, the daily updater pins the outgoing release by
itself, so no channel vanishes. `majorPattern` in
[.github/update.json](../.github/update.json) tells it where the major sits in
a tag.
