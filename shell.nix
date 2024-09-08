with import <nixpkgs> { };
let
  getLibPath = lib: builtins.concatStringsSep ":" (map (lib: "${lib.out.outPath}/lib") lib);
  inherit (llvmPackages_18) stdenv;
  rust-jemalloc-sys' = rust-jemalloc-sys.override {
    jemalloc = jemalloc.override { disableInitExecTls = true; };
  };
  general-libs = [
    glib
    pango
    harfbuzz
    fontconfig.lib
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
    [
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
      export ${varPrefix}_LIBRARY_PATH="${getLibPath general-libs}"
    '';
}
