#!/bin/bash


if [[ $target_platform == linux-aarch64 ]]; then
    # it takes too much time to compile, so we reduce the supported archs on aarch64
    export NVCC_GENCODE="-gencode=arch=compute_60,code=sm_60 \
                         -gencode=arch=compute_70,code=sm_70 \
                         -gencode=arch=compute_80,code=sm_80 \
                         -gencode=arch=compute_80,code=compute_80"
    make -j${CPU_COUNT} src.lib CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart" NVCC_GENCODE="$NVCC_GENCODE"
else
    make -j${CPU_COUNT} src.lib CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart"
fi

make install PREFIX="${PREFIX}"
