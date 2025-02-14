{ buildPythonPackage, poetry-core, orjson, pydantic, httpx, fetchFromGitHub }:

buildPythonPackage rec {
      pname = "mistralai";
      version = "0.4.1";
      pyproject = true;
      src = fetchFromGitHub {
        owner="mistralai";
        repo="client-python";
        rev="0.4.1";
        hash = "sha256-4FkQXqE/oJr3xNwp5qdX/aFHTpJCwMqzHREgbiO5VTA=";
      };
      nativeBuildInputs = [ poetry-core ];
      propagatedBuildInputs = [ orjson pydantic httpx ];
      pythonImportCheckds = [ "mistralai" ];
}
