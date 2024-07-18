{
  lib,
  stdenv,
  python,
  buildPythonPackage,
  pythonRelaxDepsHook,
  fetchFromGitHub,
  which,
  ninja,
  cmake,
  packaging,
  setuptools,
  torch,
  outlines,
  wheel,
  psutil,
  ray,
  pandas,
  pyarrow,
  sentencepiece,
  numpy,
  transformers,
  xformers,
  fastapi,
  uvicorn,
  pydantic,
  aioprometheus,
  pynvml,
  openai,
  pyzmq,
  tiktoken,
  torchvision,
  py-cpuinfo,
  lm-format-enforcer,
  prometheus-fastapi-instrumentator,
  cupy,
  writeShellScript,

  config,

  cudaSupport ? config.cudaSupport,
  cudaPackages ? { },

  rocmSupport ? config.rocmSupport,
  rocmPackages ? { },
  gpuTargets ? [ ],
}:

let
  stdenv_pkg = stdenv;
  cutlass = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cutlass";
    rev = "v3.5.0";
    sha256 = "sha256-D/s7eYsa5l/mfx73tE4mnFcTQdYqGmXa9d9TCryw4e4=";
  };
in

buildPythonPackage rec {
  pname = "vllm";
  version = "0.5.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "vllm-project";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-CUyYTmV1+Clt/npBVJlm0lhqb4vDD8MYABnw62fZVVI=";
  };

  # Otherwise it tries to enumerate host supported ROCM gfx archs, and that is not possible due to sandboxing.
  PYTORCH_ROCM_ARCH = lib.optionalString rocmSupport (
    lib.strings.concatStringsSep ";" rocmPackages.clr.gpuTargets
  );

  # cupy-cuda12x is the same wheel as cupy, but built with cuda dependencies, we already have it set up
  # like that in nixpkgs. Version upgrade is due to upstream shenanigans
  # https://github.com/vllm-project/vllm/pull/2845/commits/34a0ad7f9bb7880c0daa2992d700df3e01e91363
  #
  # hipcc --version works badly on NixOS due to unresolved paths.
  postPatch = ''
    substituteInPlace setup.py \
      --replace 'cmake_args = [' 'cmake_args = ["-DFETCHCONTENT_SOURCE_DIR_CUTLASS=${cutlass}",'
    '' +
    lib.optionalString rocmSupport ''
      substituteInPlace setup.py \
        --replace "'hipcc', '--version'" "'${writeShellScript "hipcc-version-stub" "echo HIP version: 0.0"}'"
    '';

  preBuild = lib.optionalString rocmSupport ''
      export ROCM_HOME=${rocmPackages.clr}
      export PATH=$PATH:${rocmPackages.hipcc}
    '' + lib.optionalString cudaSupport ''
      export CUDA_HOME=${cudaPackages.cudatoolkit}
    '';

  nativeBuildInputs = [
    packaging
    setuptools
    torch
    wheel
    which
    cmake
    ninja
    pythonRelaxDepsHook #unclear why this is needed, but it seems to be
  ] ++ lib.optionals rocmSupport [ rocmPackages.hipcc ];

  buildInputs =
    (lib.optionals cudaSupport (
      with cudaPackages;
      [
        cudatoolkit
        cuda_cudart.dev # cuda_runtime.h, -lcudart
        cuda_cudart.lib
        cuda_cccl.dev # <thrust/*>
        libcusparse.dev # cusparse.h
        libcusolver # cusolverDn.h
      ]
    ))
    ++ (lib.optionals rocmSupport (
      with rocmPackages;
      [
        clr
        rocthrust
        rocprim
        hipsparse
        hipblas
      ]
    ));

  propagatedBuildInputs =
    [
      psutil
      ray
      pandas
      pyarrow
      sentencepiece
      numpy
      torch
      transformers
      outlines
      xformers
      fastapi
      uvicorn
      pydantic
      aioprometheus
      openai
      pyzmq
      tiktoken
      torchvision
      py-cpuinfo
      lm-format-enforcer
      prometheus-fastapi-instrumentator
    ]
    ++ uvicorn.optional-dependencies.standard
    ++ aioprometheus.optional-dependencies.starlette
    ++ lib.optionals cudaSupport [
      pynvml
      cupy
    ];

  dontUseCmakeConfigure=true;

  pythonRelaxDeps = true;

  stdenv = if cudaSupport then cudaPackages.backendStdenv else stdenv;

  pythonImportsCheck = [ "vllm" ];

  meta = with lib; {
    description = "High-throughput and memory-efficient inference and serving engine for LLMs";
    changelog = "https://github.com/vllm-project/vllm/releases/tag/v${version}";
    homepage = "https://github.com/vllm-project/vllm";
    license = licenses.asl20;
    maintainers = with maintainers; [
      happysalada
      lach
    ];
    broken = !cudaSupport && !rocmSupport;
  };
}
