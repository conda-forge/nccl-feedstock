#!/bin/bash

set -ex

[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
# https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html?highlight=tegra#cross-compilation
[[ ${target_platform} == "linux-aarch64" && ${arm_variant_type} == "sbsa" ]] && targetsDir="targets/sbsa-linux"
[[ ${target_platform} == "linux-aarch64" && ${arm_variant_type} == "tegra" ]] && targetsDir="targets/aarch64-linux"

if [ -z "${targetsDir+x}" ]; then
    echo "target_platform: ${target_platform} is unknown! targetsDir must be defined!" >&2
    exit 1
fi

if [[ -z "${CUDA_HOME+x}" ]]; then
  # `$CUDA_HOME` was set for CUDA 11.x and earlier.
  # Must be using CUDA 12.0+. So set to `$BUILD_PREFIX`.
  # This is needed to find `nvcc` and `cudart`.
  export CUDA_HOME="${BUILD_PREFIX}"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
    if [[ "${target_platform}" == "linux-aarch64" ]]; then
        if [[ "${arm_variant_type}" == "tegra" ]]; then
            export CUDA_LIB="${CUDA_HOME}/targets/aarch64-linux/lib/"
        else
            export CUDA_LIB="${CUDA_HOME}/targets/sbsa-linux/lib/"
        fi
    elif [[ "${target_platform}" == "linux-ppc64le" ]]; then
        export CUDA_LIB="${CUDA_HOME}/targets/ppc64le-linux/lib/"
    else
        echo "not supported"
        exit 1
    fi
fi

# For now, we emit LLVM IR for CUDA 12.x only.
if [[ "${cuda_compiler_version}" == 12.* ]]; then
    EMIT_LLVM_IR=1
else
    EMIT_LLVM_IR=0
fi

# NCCL's Makefile assumes a standard system-wide CUDA installation where
# everything lives under one directory (e.g. /usr/local/cuda/include,
# /usr/local/cuda/bin/nvcc, etc.). Conda does not install CUDA that way.
# Instead, CUDA is split across many small packages and headers live under
# platform-specific target directories like:
#   $BUILD_PREFIX/targets/x86_64-linux/include/
#   $BUILD_PREFIX/targets/sbsa-linux/include/
#
# We override NCCL Makefile's CUDA_HOME, CUDA_INC, NVCC
# to point at the actual conda paths. None of this would be needed if CUDA
# were installed the standard way.

# CUDA_INC: tells nvcc/gcc where to find CUDA headers (cuda.h, etc.)
# when compiling libnccl.so. Must point to the target platform's headers.
CUDA_INC="$BUILD_PREFIX/$targetsDir/include"

# Also there is another issue with clang at https://github.com/llvm/llvm-project/blob/dfcbf6c70e7088e4b10e9c9c47bdfa19eb031228/clang/lib/Headers/__clang_cuda_runtime_wrapper.h#L483-L493
# Maybe clang should have #if __has_include("curand_mtgp32_kernel.h") so it will not
# unconditionally include the header.
# NCCL does not need this header so just touch the file so clang can find it.
# Listing libcurand-dev as a host dependency won't help because clang needs it in the
# build env. Listing it as a build: dependency breaks cross-compilation for linux-aarch64
touch "$BUILD_PREFIX/$targetsDir/include/curand_mtgp32_kernel.h"

make -j1 pkg.txz.build EMIT_LLVM_IR="$EMIT_LLVM_IR" \
  CUDA_HOME="$BUILD_PREFIX" \
  CUDA_INC="$CUDA_INC" \
  NVCC="$BUILD_PREFIX/bin/nvcc"

make install PREFIX="${PREFIX}"

# Delete static library
rm "${PREFIX}/lib/libnccl_static.a"

check-glibc $PREFIX/bin/* $PREFIX/lib/lib*.so*
