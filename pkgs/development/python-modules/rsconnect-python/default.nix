{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pip,
  semver,
  pyjwt,
  click,
  typing-extensions,
  setuptools,
  setuptools-scm
}:

buildPythonPackage rec {
  pname = "rsconnect-python";
  version = "1.2.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cfhammill";
    repo = pname;
    rev = "0cadedf246b8d76d795d99a2c778017fa9a9e1ab";
    hash = "sha256-scIdUiUQuW/7oC2ZNeyWRg/lm8C1BSOBOKVh/2a5t9c=";
  };

  build-system = [ setuptools setuptools-scm ];

  dependencies = [
    typing-extensions
    pip
    semver
    pyjwt
    click
  ];

  meta = with lib; {
    description = "The rsconnect-python CLI";
    changelog = "https://github.com/posit-dev/rsconnect-python/releases/tag/v${version}";
    homepage = "https://github.com/posit-dev/rsconnect-python/blob/${version}/CHANGELOG.md";
    license = licenses.gpl2;
    maintainers = with maintainers; [ cfhammill ];
  };
}
