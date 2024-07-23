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
}@args:

let
  cutlass = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "cutlass";
    rev = "refs/tags/v3.5.0";
    sha256 = "sha256-D/s7eYsa5l/mfx73tE4mnFcTQdYqGmXa9d9TCryw4e4=";
  };
in

buildPythonPackage rec {
  pname = "vllm";
  version = "0.5.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "cfhammill";
    repo = pname;
    rev = "mig-fix";
    hash = "sha256-sqJVqYnHJWEOUbPalDvWfrsKjTsgDEdfcK0fy7fQEx0=";
  };

  stdenv = if cudaSupport then cudaPackages.backendStdenv else args.stdenv;

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
      export CUDA_HOME=${cudaPackages.cuda_nvcc}
    '';

  nativeBuildInputs = [
    cmake
    ninja
    packaging
    pythonRelaxDepsHook # not sure why this is needed, but it is
    setuptools
    torch
    wheel
    which
  ] ++ lib.optionals rocmSupport [ rocmPackages.hipcc ];

  buildInputs =
    (lib.optionals cudaSupport
      (with cudaPackages; [
        cuda_cudart # cuda_runtime.h, -lcudart
        cuda_cccl
        libcusparse # cusparse.h
        libcusolver # cusolverDn.h
        cuda_nvcc
        cuda_nvtx
        libcublas
      ]))
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
      aioprometheus
      fastapi
      lm-format-enforcer
      numpy
      openai
      outlines
      pandas
      prometheus-fastapi-instrumentator
      psutil
      py-cpuinfo
      pyarrow
      pydantic
      pyzmq
      ray
      sentencepiece
      tiktoken
      torch
      torchvision
      transformers
      uvicorn
      xformers
    ]
    ++ uvicorn.optional-dependencies.standard
    ++ aioprometheus.optional-dependencies.starlette
    ++ lib.optionals cudaSupport [
      cupy
      pynvml
    ];

  dontUseCmakeConfigure=true;

  pythonRelaxDeps = true;

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
