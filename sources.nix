{
  version = "cachyos-11.0-20260702-slr";
  variants = {
    x86_64 = "sha256-ZyyhEf6NcW7MzswWAlMdE4Ok8KnBOmB81yvu8ZwVxl4=";
    x86_64_v3 = "sha256-pbx/WDgpa55WDr1exD4rrNWsRoVkqHIUjzX1PJObxG8=";
    arm64 = "sha256-NgoWTok8N41B4vh4bj0VOiAQzJiTFrkbpr4DnoTFRoY=";
  };
  pins = {
    "cachyos-10.0-sunset-slr" = {
      variants = {
        x86_64 = "sha256-6sSp55dEzPrLTUp3drsqYvp5+635aBT3JRFC2BYCCC4=";
        x86_64_v3 = "sha256-Q8AsXnjukewCd3th3wSzfWmjujJcCb//FvvQfeZ6/XM=";
      };
    };
  };
}
