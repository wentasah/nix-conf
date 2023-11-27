{ lib
, buildPythonPackage
, fetchFromGitHub
, pyclothoids
, setuptools
, pytest
, numpy
, lxml
, scipy
, xmlschema
}:
buildPythonPackage rec {
  pname = "scenariogeneration";
  version = "0.13.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pyoscx";
    repo = "scenariogeneration";
    rev = "v${version}";
    hash = "sha256-ayg6eGkcX6vw1KFyl19YLjGBVnCaC13aGDYCcnJFA0U=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  nativeCheckInputs = [
    pytest
  ];

  propagatedBuildInputs = [
    numpy
    lxml
    scipy
    xmlschema
    pyclothoids
  ];

  pythonImportsCheck = [ "scenariogeneration" ];

  meta = with lib; {
    description = "Python library to generate linked OpenDRIVE and OpenSCENARIO files";
    homepage = "https://github.com/pyoscx/scenariogeneration";
    license = licenses.mpl20;
    maintainers = with maintainers; [ ];
  };
}
