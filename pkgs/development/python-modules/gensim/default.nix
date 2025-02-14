{
  lib,
  buildPythonPackage,
  cython,
  oldest-supported-numpy,
  setuptools,
  fetchFromGitHub,
  mock,
  numpy,
  scipy,
  smart-open,
  pyemd,
  pytestCheckHook,
  pythonOlder,
  pythonRelaxDepsHook
}:

buildPythonPackage rec {
  pname = "gensim";
  version = "4.3.3";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "piskvorky";
    repo = "gensim";
    ref = "release-4.3.3";
    hash = "sha256-hIagdqaj2I19rFviReJMIcO4GbVl4UwbYfo+Xudtz1c=";
  };

  build-system = [
    cython
    oldest-supported-numpy
    setuptools
    pythonRelaxDepsHook
  ];

  dependencies = [
    smart-open
    numpy
    scipy
  ];

  nativeCheckInputs = [
    mock
    pyemd
    pytestCheckHook
  ];

  postPatch = ''
    substituteInPlace pyproject.toml --replace "Cython>=0.29.32,<3.0.0" "Cython"
  '';

  pythonRelaxDeps = [
    "scipy"
  ];

  pythonImportsCheck = [ "gensim" ];

  # Test setup takes several minutes
  doCheck = false;

  pytestFlagsArray = [ "gensim/test" ];

  meta = with lib; {
    description = "Topic-modelling library";
    homepage = "https://radimrehurek.com/gensim/";
    changelog = "https://github.com/RaRe-Technologies/gensim/blob/${version}/CHANGELOG.md";
    license = licenses.lgpl21Only;
    maintainers = with maintainers; [ jyp ];
  };
}
