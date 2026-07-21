{
  lib,
  stdenvNoCC,
  fetchzip,
  variant ? "x86_64",
  steamDisplayName ? null,
}:
let
  hashX64 = "sha256-ZyyhEf6NcW7MzswWAlMdE4Ok8KnBOmB81yvu8ZwVxl4=";
  hashV3 = "sha256-pbx/WDgpa55WDr1exD4rrNWsRoVkqHIUjzX1PJObxG8=";
  hashArm64 = "sha256-NgoWTok8N41B4vh4bj0VOiAQzJiTFrkbpr4DnoTFRoY=";
  version = "cachyos-11.0-20260702-slr";
  variantSrc =
    v: hash:
    fetchzip {
      url = "https://github.com/CachyOS/proton-cachyos/releases/download/${version}/proton-${version}-${v}.tar.xz";
      inherit hash;
    };
  variantSrcs = {
    x86_64 = variantSrc "x86_64" hashX64;
    x86_64_v3 = variantSrc "x86_64_v3" hashV3;
    arm64 = variantSrc "arm64" hashArm64;
  };
  stableNames = {
    x86_64 = "proton-cachyos";
    x86_64_v3 = "proton-cachyos-v3";
    arm64 = "proton-cachyos-arm64";
  };
  displayName = if steamDisplayName == null then stableNames.${variant} else steamDisplayName;
in
stdenvNoCC.mkDerivation {
  pname = "proton-cachyos" + lib.optionalString (variant != "x86_64") "-${variant}";
  inherit version;

  src = variantSrcs.${variant};

  allVariantSources = lib.optionals (variant == "x86_64") (lib.attrValues variantSrcs);

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;

  outputs = [
    "out"
    "steamcompattool"
  ];

  installPhase = ''
    runHook preInstall
    echo "proton-cachyos is a Steam compatibility tool; consume the steamcompattool output via programs.steam.extraCompatPackages." > $out
    mkdir $steamcompattool
    ln -s $src/* $steamcompattool
    rm $steamcompattool/compatibilitytool.vdf
    cp $src/compatibilitytool.vdf $steamcompattool
    substituteInPlace "$steamcompattool/compatibilitytool.vdf" \
      --replace-fail "proton-${version}-${variant}" "${displayName}"
    runHook postInstall
  '';

  meta = {
    description = "Proton-CachyOS prebuilt Steam Play compatibility tool (${variant} build)";
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = lib.licenses.bsd3;
    platforms = if variant == "arm64" then [ "aarch64-linux" ] else [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
