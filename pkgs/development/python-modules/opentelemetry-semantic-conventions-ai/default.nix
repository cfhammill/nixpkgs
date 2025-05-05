{
  fetchPypi,
  buildPythonPackage,
  poetry-core
}:

buildPythonPackage rec {
  pname = "opentelemetry-semantic-conventions-ai";
  version = "0.4.5";
  pyproject = true;

  src = fetchPypi {
    inherit version;
    pname = "opentelemetry_semantic_conventions_ai";
    hash = "sha256-FeJUCqgH+2dI8b3GDakz7i+y5A9t7Ej96PrP2eIlUNc=";
  };

  build-system = [
    poetry-core
  ];

}
