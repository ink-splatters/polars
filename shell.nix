with import <nixpkgs> { };
let
  inherit (llvmPackages_18) stdenv;
  rust-jemalloc-sys' = rust-jemalloc-sys.override {
    jemalloc = jemalloc.override { disableInitExecTls = true; };
  };
in
mkShell.override { inherit stdenv; } rec {
  nativeBuildInputs = [
    clang_18
    llvm_18
    gnumake
    cmake
    ninja
    nodejs_22
  ];

  cmakeFlags = [
    "-GNinja"
  ];

  buildInputs =
    [ zlib-ng rust-jemalloc-sys' ]
    ++ lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk.frameworks;
      [
        AppKit
        CoreFoundation
        Foundation
        IOKit
        Security
        System
        SystemConfiguration
      ]
      ++ [ iconv ]
    );
}
