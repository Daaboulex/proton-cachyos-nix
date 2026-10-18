{
  version = "cachyos-11.0-20261014-slr";
  # std:variants-begin
  variants = {
    arm64 = "sha256-KMCfVYTs1P+6JZ+T1qzZuj/jUja2rVdnFmOYQhV942w=";
    x86_64 = "sha256-L0CzBfelMJP2jj4VNEQY/ZswJo16TN6nNf9qKVryCRU=";
    x86_64_v3 = "sha256-fHi/LfyvPj2qm8ma6JH+wEJiJO1Htwp6zkbdRSg6Xic=";
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
