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
  ];

  cmakeFlags = [
    "-GNinja"
  ];

  buildInputs =
    [ rust-jemalloc-sys' ]
    ++ lib.optionals stdenv.isDarwin (
      with darwin.apple_sdk.frameworks;
      [
        Security
        SystemConfiguration
      ]
      ++ [ iconv ]
    );
}
