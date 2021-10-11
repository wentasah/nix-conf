{rustPlatform, fetchFromGitHub, pkg-config, openssl}:
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
  buildInputs = [ openssl ];

  cargoSha256 = "01p1fv66axfimaz2xaj5phwdjr3m7ixy9mk9vbgmybrdwgk43rfa";
}
