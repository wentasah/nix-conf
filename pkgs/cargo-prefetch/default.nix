{rustPlatform, fetchFromGitHub, pkg-config, openssl_1_1}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-prefetch";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ehuss";
    repo = pname;
    rev = "08bbc066b608ae849a4ff8c40aa64fa3193f90b0"; # version;
    sha256 = "04m8n42x4fhjsybpr5idylihdmfbkcwfr8mz2vb1kq5lqs88hplj";
  };

  nativeBuildInputs = [ pkg-config ];

  # Broken with openssl 3; needs 1.1. See
  # https://github.com/sfackler/rust-openssl/issues/1663 for similar error.
  buildInputs = [ openssl_1_1 ];

  cargoSha256 = "01p1fv66axfimaz2xaj5phwdjr3m7ixy9mk9vbgmybrdwgk43rfa";
}
