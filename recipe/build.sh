#!/bin/bash


[[ ${target_platform} == "linux-64" ]] && targetsDir="targets/x86_64-linux"
[[ ${target_platform} == "linux-ppc64le" ]] && targetsDir="targets/ppc64le-linux"
[[ ${target_platform} == "linux-aarch64" ]] && targetsDir="targets/sbsa-linux"

export CFLAGS="${CFLAGS} -I${PREFIX}/${targetsDir}/include"
export CXXFLAGS="${CXXFLAGS} -I${PREFIX}/${targetsDir}/include"

if [[ $target_platform == linux-aarch64 || ($target_platform == linux-ppc64le && $cuda_compiler_version != "10.2")]]; then
    # it takes too much time to compile, so we reduce the supported archs on aarch64
    export NVCC_GENCODE="-gencode=arch=compute_60,code=[compute_60,sm_60] \
                         -gencode=arch=compute_70,code=[compute_70,sm_70] \
                         -gencode=arch=compute_80,code=[compute_80,sm_80]"
    make -j${CPU_COUNT} src.lib CUDA_HOME="${PREFIX}" CUDARTLIB="cudart_static" NVCC_GENCODE="$NVCC_GENCODE"
else
    make -j${CPU_COUNT} src.lib CUDA_HOME="${PREFIX}" CUDARTLIB="cudart_static"
fi

make install PREFIX="${PREFIX}"

# Delete static library
rm "${PREFIX}/lib/libnccl_static.a"
