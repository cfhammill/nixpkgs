{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  pydantic,
  interegular,
  pyyaml,
  poetry-core
}:

buildPythonPackage rec {
  pname = "lm-format-enforcer";
  version = "0.10.4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "noamgat";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-GOnMj910rgzYeIeN2yLcXZDDel/Hu6nv7ov5BrlHJLg=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs =
    [
      pydantic
      interegular
      pyyaml
    ];

  meta = with lib; {
    description = "Enforce the output format (JSON Schema, Regex etc) of a language model";
    changelog = "https://github.com/noamgat/lm-format-enforcer/releases/tag/v${version}";
    homepage = "https://github.com/noamgat/lm-format-enforcer";
    license = licenses.mit;
    maintainers = with maintainers; [
      cfhammill
    ];
  };
}

