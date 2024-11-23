{ lib, buildNpmPackage, fetchFromGitHub }:

buildNpmPackage {
  pname = "svlangserver";
  version = "0.4.1+git";

  src = fetchFromGitHub {
    owner = "imc-trading";
    repo = "svlangserver";
    rev = "59c97307b0a02d3e114ff4546def71b94f55e19c";
    sha256 = "0awp172hdyb0hry6ana78xxvvqj5kv8f6ch5cx0rb0mg4hl2mqll";
    # date = "2024-05-21T06:35:05-05:00";
  };

  npmDepsHash = "sha256-7j9TE1QkqymOWKjE1tSA8n9AJ2nSyjQoDq/8jptIPwY=";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];

  #NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    description = "A language server for systemverilog that has been tested to work with coc.nvim, VSCode, Sublime Text 4, emacs, and Neovim";
    homepage = "https://github.com/imc-trading/svlangserver";
    license = licenses.mit;
    maintainers = with maintainers; [ wentasah ];
  };
}
