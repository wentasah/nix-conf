{ lib
, python3
, fetchFromGitHub
}:
python3.pkgs.buildPythonApplication rec {
  pname = "pyclothoids";
  version = "0.1.5";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "phillipd94";
    repo = "pyclothoids";
    rev = "v${version}";
    hash = "sha256-60TZln/OWb+NH98BQMZB5IAuLlbydvkcggGcQx6h6gs=";
    fetchSubmodules = true;
  };

  # Prevent the following error:
  # ImportError: cannot import name 'ClothoidCurve' from 'pyclothoids._clothoids_cpp' (/build/source/pyclothoids/_clothoids_cpp/__init__.py)
  postPatch = ''
    rm -rf pyclothoids/_clothoids_cpp
  '';

  nativeBuildInputs = with python3.pkgs; [
    setuptools
  ];

  propagatedBuildInputs = with python3.pkgs; [
    pybind11
  ];

  pythonImportsCheck = [ "pyclothoids" ];

  meta = with lib; {
    description = "A Python library for clothoid curves";
    homepage = "https://github.com/phillipd94/pyclothoids";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}
