#!/bin/bash

EXTRA_ARGS="CUDARTLIB=\"cudart_static\""

if [[ "${cuda_compiler_version}" =~ 12.* ]]; then
  EXTRA_ARGS="${EXTRA_ARGS} CUDA_HOME=\"${PREFIX}\" NVCC=\"${BUILD_PREFIX}/bin/nvcc\""
elif [[ "${cuda_compiler_version}" != "None" ]]; then
  EXTRA_ARGS="${EXTRA_ARGS} CUDA_HOME=\"${CUDA_PATH}\""
fi

if [[ $CONDA_BUILD_CROSS_COMPILATION == "1" ]]; then
    if [[ $target_platform == linux-aarch64 ]]; then
        EXTRA_ARGS="${EXTRA_ARGS} CUDA_LIB=\"${CUDA_HOME}/targets/sbsa-linux/lib/\""
    elif [[ $target_platform == linux-ppc64le ]]; then
        EXTRA_ARGS="${EXTRA_ARGS} CUDA_LIB=\"${CUDA_HOME}/targets/ppc64le-linux/lib/\""
    else
        echo "not supported"
        exit -1
    fi
fi

# `eval` is needed here for proper `${...}` expansion
eval make -j${CPU_COUNT} src.lib ${EXTRA_ARGS}

make install PREFIX="${PREFIX}"

# Delete static library
rm "${PREFIX}/lib/libnccl_static.a"
