#!/bin/bash


#if [[ $target_platform == linux-aarch64 || ($target_platform == linux-ppc64le && $cuda_compiler_version != "10.2")]]; then
#    # it takes too much time to compile, so we reduce the supported archs on aarch64
#    export NVCC_GENCODE="-gencode=arch=compute_60,code=[compute_60,sm_60] \
#                         -gencode=arch=compute_70,code=[compute_70,sm_70] \
#                         -gencode=arch=compute_80,code=[compute_80,sm_80]"
#    make -j${CPU_COUNT} src.lib CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart_static" NVCC_GENCODE="$NVCC_GENCODE"
#else
#    make -j${CPU_COUNT} src.lib CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart_static"
#fi

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
