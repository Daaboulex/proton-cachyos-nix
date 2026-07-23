{
  pkgs,
  lib ? pkgs.lib,
}:
let
  sources = import ./sources.nix;

  majorOf = tag: lib.head (builtins.match "cachyos-([0-9]+)\\..*" tag);
  tagLabel = tag: lib.removeSuffix "-slr" (lib.removePrefix "cachyos-" tag);

  allReleases = {
    ${sources.version} = {
      inherit (sources) variants;
    };
  }
  // sources.pins;

  variantDisplaySuffix = v: if v == "x86_64" then "" else " " + lib.removePrefix "x86_64_" v;
  variantAttrSuffix = v: if v == "x86_64" then "" else "-" + lib.removePrefix "x86_64_" v;

  mk =
    tag: variant: steamDisplayName:
    pkgs.callPackage ./package.nix {
      inherit tag variant steamDisplayName;
      hash = allReleases.${tag}.variants.${variant};
    };

  hasVariant = tag: variant: allReleases.${tag}.variants ? ${variant};

  channelsForVariant =
    variant:
    let
      pinTags = lib.filter (t: hasVariant t variant) (lib.attrNames allReleases);
    in
    lib.listToAttrs (
      map (tag: {
        name = "v${majorOf tag}";
        value = mk tag variant "Proton-CachyOS ${tagLabel tag}${variantDisplaySuffix variant}";
      }) pinTags
    )
    // {
      latest = mk sources.version variant "Proton-CachyOS-latest${variantDisplaySuffix variant}";
    };

  withChannels =
    chans:
    chans.latest.overrideAttrs (old: {
      passthru = (old.passthru or { }) // chans;
    });

  liveVariants = lib.attrNames sources.variants;

  perVariant = lib.listToAttrs (
    map (v: {
      name = "proton-cachyos${variantAttrSuffix v}";
      value = withChannels (channelsForVariant v);
    }) liveVariants
  );
in
perVariant
// {
  channels = lib.genAttrs liveVariants channelsForVariant;
}
