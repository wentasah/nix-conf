{ lib
, python3
, fetchFromGitHub
#, callPackage
, pyclothoids #? callPackage ./pyclothoids.nix { }
}:
python3.pkgs.buildPythonApplication rec {
  pname = "scenariogeneration";
  version = "0.13.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "pyoscx";
    repo = "scenariogeneration";
    rev = "v${version}";
    hash = "sha256-ayg6eGkcX6vw1KFyl19YLjGBVnCaC13aGDYCcnJFA0U=";
  };

  nativeBuildInputs = with python3.pkgs; [
    setuptools
  ];

  nativeCheckInputs = with python3.pkgs; [
    pytest
  ];

  propagatedBuildInputs = (with python3.pkgs; [
    numpy
    lxml
    scipy
    xmlschema
  ]) ++ [
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
