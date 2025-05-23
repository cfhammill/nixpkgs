{
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  requests,
  tqdm,
  pytest,
  pytest-xdist,
  pytest-repeat,
  pytest-rerunfailures,
  pytest-asyncio,
  tabulate,
  sentry-sdk,
  rich,
  coverage,
  black,
  portalocker,
  openai,
  twine,
  aiohttp,
  typer,
  ollama,
  setuptools,
  wheel,
  nest-asyncio,
  tenacity,
  opentelemetry-api,
  opentelemetry-sdk,
  opentelemetry-exporter-otlp-proto-grpc,
  grpcio,
  anthropic,
  google-genai,
  posthog,
  langchain-community,
  langchain-openai
}:

buildPythonPackage rec {
  pname = "deepeval";
  version = "2.9.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "confident-ai";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-muOW2Dv/JVuvg0RfvU+LprpSgGIvi6USH8wfZ5+X5cM=";
  };

  build-system = [
    poetry-core
  ];

  dependencies = [
    requests
    tqdm
    pytest
    pytest-xdist
    pytest-repeat
    pytest-rerunfailures
    pytest-asyncio
    tabulate
    sentry-sdk
    rich
    coverage
    black
    portalocker
    openai
    twine
    aiohttp
    typer
    ollama
    setuptools
    wheel
    nest-asyncio
    tenacity
    opentelemetry-api
    opentelemetry-sdk
    opentelemetry-exporter-otlp-proto-grpc
    grpcio
    anthropic
    google-genai
    posthog
    langchain-community
    langchain-openai
  ];

  pythonRelaxDeps = [ "pytest-rerunfailures" "rich" "twine" ];
}
