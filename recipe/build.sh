#!/bin/bash

if [[ -z "${CUDA_HOME+x}" ]]; then
  # `$CUDA_HOME` was set for CUDA 11.x and earlier.
  # Must be using CUDA 12.0+. So set to `$BUILD_PREFIX`.
  # This is needed to find `nvcc` and `cudart`.
  export CUDA_HOME="${BUILD_PREFIX}"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" ]]; then
    if [[ "${target_platform}" == "linux-aarch64" ]]; then
        export CUDA_LIB="${CUDA_HOME}/targets/sbsa-linux/lib/"
    elif [[ "${target_platform}" == "linux-ppc64le" ]]; then
        export CUDA_LIB="${CUDA_HOME}/targets/ppc64le-linux/lib/"
    else
        echo "not supported"
        exit 1
    fi
fi

make -j${CPU_COUNT} src.lib

make install PREFIX="${PREFIX}"

# Delete static library
rm "${PREFIX}/lib/libnccl_static.a"
