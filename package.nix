{
  lib,
  stdenvNoCC,
  fetchzip,
  tag,
  variant,
  hash,
  steamDisplayName ? "Proton-CachyOS",
}:
let
  attrTail = if variant == "x86_64" then "" else "-" + lib.removePrefix "x86_64_" variant;
in
stdenvNoCC.mkDerivation {
  pname = "proton-cachyos${attrTail}";
  version = tag;

  src = fetchzip {
    url = "https://github.com/CachyOS/proton-cachyos/releases/download/${tag}/proton-${tag}-${variant}.tar.xz";
    inherit hash;
  };

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
      --replace-fail "proton-${tag}-${variant}" "${steamDisplayName}"
    runHook postInstall
  '';

  meta = {
    description = "Proton-CachyOS prebuilt Steam Play compatibility tool (${tag}, ${variant}), stable dropdown identity";
    homepage = "https://github.com/CachyOS/proton-cachyos";
    license = lib.licenses.bsd3;
    platforms = if variant == "arm64" then [ "aarch64-linux" ] else [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
