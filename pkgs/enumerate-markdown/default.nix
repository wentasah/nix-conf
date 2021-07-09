{ lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "enumerate-markdown";
  version = "0.1.0";

  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "0m69mxinwzb0586r7cn6x39hyyysrrw43wv3lydjq1ky2wa811vz";
  };

  meta = with lib; {
    homepage = "https://github.com/a4vision/enumerate-markdown";
    description = "Enumerate headers in markdown file";
    license = licenses.mit;
  };
}
