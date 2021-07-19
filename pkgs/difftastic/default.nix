{ lib, rustPlatform, fetchFromGitHub }:

rustPlatform.buildRustPackage rec {
  pname = "difftastic";
  version = "0.0.0";

  src = fetchFromGitHub {
    owner = "wilfred";
    repo = pname;
    rev = "cd243312704ff9cd1310a5bb57e22577739819c6";
    sha256 = "0lvwj3zsh8fns91rlg4hvwbw24871phhqa7wbdxldhbqaghmdsx0";
  };

  cargoSha256 = "1w6i2yxhxkhlyn789n2aypc8h29pwgs51hra2mfwwxc5xy1rzpsd";

  buildInputs = [ ];

  meta = with lib; {
    description = "a syntax-aware diff";
    homepage = "https://github.com/wilfred/difftastic/";
    license = licenses.mit;
    maintainers = with maintainers; [ wentasah ];
  };
}
