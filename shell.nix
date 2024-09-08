with import <nixpkgs> { };
let
  inherit (llvmPackages_18) stdenv;
  rust-jemalloc-sys' = rust-jemalloc-sys.override {
    jemalloc = jemalloc.override { disableInitExecTls = true; };
  };
  general-libs = [
    glib
    pango
    harfbuzz
    fontconfig
  ];
in
mkShell.override { inherit stdenv; } rec {
  nativeBuildInputs = [
    clang_18
    llvm_18
    gnumake
    pandoc
    texliveMinimal
    cmake
    ninja
  ];

  cmakeFlags = [
    "-GNinja"
  ];

  buildInputs =
    general-libs
    ++ [
      zlib-ng
      rust-jemalloc-sys'
    ]
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

  shellHook =
    let
      varPrefix = if stdenv.isDarwin then "DYLD" else "LD";
    in
    ''
      export ${varPrefix}_LIBRARY_PATH="${lib.makeLibraryPath general-libs}"
    '';
}
