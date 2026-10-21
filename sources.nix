{
  version = "cachyos-11.0-20261015-slr";
  # std:variants-begin
  variants = {
    arm64 = "sha256-xV683d43wjkDyERXknf4yDzQbWVlD3w+Wo4H6AxeIis=";
    x86_64 = "sha256-Vb1AvDQLIpgxr3ABPMstM3DFRN1tfUD+6OnhQirMnAQ=";
    x86_64_v3 = "sha256-USZ7wVV069xmGJdtyg6b/pdv7qqLkUkSZEyHiiVIs1o=";
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
