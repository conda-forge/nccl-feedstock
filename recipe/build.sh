#!/bin/bash


if [[ $CONDA_BUILD_CROSS_COMPILATION == "1" ]]; then
    if [[ $target_platform == linux-aarch64 ]]; then
        make -j${CPU_COUNT} src.lib CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart_static" CUDA_LIB="${CUDA_HOME}/targets/sbsa-linux/lib/"
    elif [[ $target_platform == linux-ppc64le ]]; then
        make -j${CPU_COUNT} src.lib CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart_static" CUDA_LIB="${CUDA_HOME}/targets/ppc64le-linux/lib/"
    else
        echo "not supported"
        exit -1
    fi
else
    make -j${CPU_COUNT} src.lib CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart_static"
fi
make install PREFIX="${PREFIX}"

# Delete static library
rm "${PREFIX}/lib/libnccl_static.a"
