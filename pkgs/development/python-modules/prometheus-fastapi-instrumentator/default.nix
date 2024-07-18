{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  starlette,
  prometheus-client,
  poetry-core
}:

buildPythonPackage rec {
  pname = "prometheus-fastapi-instrumentator";
  version = "7.0.0";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "trallnag";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-yvKdhQdbY0+jEc8TEHNNgtdnqE0abnd4MN/JZFQwQ2E=";
  };

  nativeBuildInputs = [ poetry-core ];

  propagatedBuildInputs =
    [
      starlette
      prometheus-client
    ];

  meta = with lib; {
    description = "A configurable and modular Prometheus Instrumentator for your FastAPI.";
    changelog = "https://github.com/prometheus-fastapi-instrumentator/releases/releases/tag/v${version}";
    homepage = "https://github.com/prometheus-fastapi-instrumentator/releases";
    license = licenses.isc;
    maintainers = with maintainers; [
      cfhammill
    ];
  };
}
