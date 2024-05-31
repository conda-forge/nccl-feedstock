#!/bin/bash

if [[ "${cuda_compiler_version}" =~ 12.* ]]; then
  export CUDA_HOME=${BUILD_PREFIX}
elif [[ "${cuda_compiler_version}" != "None" ]]; then
  export CUDA_HOME=${CUDA_PATH}
fi

if [[ $CONDA_BUILD_CROSS_COMPILATION == "1" ]]; then
    if [[ $target_platform == linux-aarch64 ]]; then
        export CUDA_LIB=${CUDA_HOME}/targets/sbsa-linux/lib/
    elif [[ $target_platform == linux-ppc64le ]]; then
        export CUDA_LIB=${CUDA_HOME}/targets/ppc64le-linux/lib/
    else
        echo "not supported"
        exit -1
    fi
fi

make -j${CPU_COUNT} src.lib

make install PREFIX="${PREFIX}"

# Delete static library
rm "${PREFIX}/lib/libnccl_static.a"
