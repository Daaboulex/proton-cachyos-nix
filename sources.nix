{
  version = "cachyos-11.0-20261005-slr";
  # std:variants-begin
  variants = {
    arm64 = "sha256-yGphSPwNp0IA+V+HFL1vQP9P6qamHocnWooD8670vjE=";
    x86_64 = "sha256-qcNHgFPIG6c3q53dyeZ18fZu+cBXzs5npyxgj/WIhkg=";
    x86_64_v3 = "sha256-LlAnK4fAyLrWF+Z0L9Ft4kwfoSB+g+0o9XNvKlOSZXg=";
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
