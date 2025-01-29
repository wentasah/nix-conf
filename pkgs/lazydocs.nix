{
  lib,
  python3,
  fetchPypi, fetchFromGitHub,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "lazydocs";
  version = "0.4.8+git";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "ml-tooling";
    repo = "lazydocs";
    rev = "5a645abbc12e4c842baa51c9148a54c3a8f6a30a";
    sha256 = "05gbr0h701dcnpk5hpk3kcivq228ai4ay2fm9rxyb4lg4mm5zdfm";
    # date = "2024-01-16T14:20:10+01:00";
  };

  build-system = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  dependencies = with python3.pkgs; [
    typer
  ];

  optional-dependencies = with python3.pkgs; {
    dev = [
      black
      flake8
      isort
      mypy
      pydocstyle
      pytest
      pytest-cov
      pytest-mock
      setuptools
      twine
      wheel
    ];
  };

  pythonImportsCheck = [
    "lazydocs"
  ];

  meta = {
    description = "Generate markdown API documentation for Google-style Python docstring";
    homepage = "https://pypi.org/project/lazydocs/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wentasah ];
    mainProgram = "lazydocs";
  };
}
