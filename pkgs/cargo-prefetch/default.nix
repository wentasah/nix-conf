{rustPlatform, fetchFromGitHub, pkg-config, openssl}:
rustPlatform.buildRustPackage rec {
  pname = "cargo-prefetch";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "ehuss";
    repo = pname;
    rev = "pull/5/head"; # version;
    sha256 = "sha256-c1GcVWvz0yM89L4yNUlqaIR8SkatGpoUbOMVqVx5eGI=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-+J4WFtNnzmasQd0MoqkmRigJgPm4+UUrxQ6Zcy/4SAA=";

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ openssl ];

  cargoSha256 = "01p1fv66axfimaz2xaj5phwdjr3m7ixy9mk9vbgmybrdwgk43rfa";
}
