{
  version = "cachyos-11.0-20260703-slr";
  # std:variants-begin
  variants = {
    arm64 = "sha256-1KuZ5L0+qaPFU8P5yJVybnryD3rm+E1o/trv9+nvA7k=";
    x86_64 = "sha256-jOcPeEkBBPPNqyjXBoHm1Nk8AexPiLhx5+385NjUPT0=";
    x86_64_v3 = "sha256-8Y7orUvnFOG0zSqCrMyvmclmy3JInj7d8A2h0Y7RwhE=";
  };
  # std:variants-end
  pins = {
    "cachyos-10.0-sunset-slr" = {
      variants = {
        x86_64 = "sha256-6sSp55dEzPrLTUp3drsqYvp5+635aBT3JRFC2BYCCC4=";
        x86_64_v3 = "sha256-Q8AsXnjukewCd3th3wSzfWmjujJcCb//FvvQfeZ6/XM=";
      };
    };
  };
}
