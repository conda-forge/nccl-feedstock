#!/bin/bash

if [[ -z "${CUDA_HOME+x}" ]]; then
  # `$CUDA_HOME` was set for CUDA 11.x and earlier.
  # Must be using CUDA 12.0+. So set to `$BUILD_PREFIX`.
  # This is needed to find `nvcc` and `cudart`.
  export CUDA_HOME="${BUILD_PREFIX}"
fi

# Convert CUDAARCHS to NVCC_GENCODE if available
if [[ -n "${CUDAARCHS}" ]]; then
    NVCC_GENCODE=""
    IFS=';' read -ra ARCHS <<< "$CUDAARCHS"
    for arch_spec in "${ARCHS[@]}"; do
        # Remove any leading/trailing whitespace
        arch_spec=$(echo "$arch_spec" | xargs)

        # Parse architecture number and suffix (e.g., "87-real", "101f-virtual")
        if [[ "$arch_spec" =~ ^([0-9]+)([a-z]*)-(real|virtual)$ ]]; then
            arch_num="${BASH_REMATCH[1]}"
            arch_suffix="${BASH_REMATCH[2]}"
            code_type="${BASH_REMATCH[3]}"

            # Build the full architecture string with suffix if present
            full_arch="${arch_num}${arch_suffix}"

            if [[ "$code_type" == "real" ]]; then
                NVCC_GENCODE="${NVCC_GENCODE} -gencode=arch=compute_${full_arch},code=sm_${full_arch}"
            elif [[ "$code_type" == "virtual" ]]; then
                NVCC_GENCODE="${NVCC_GENCODE} -gencode=arch=compute_${arch_num},code=compute_${arch_num}"
            fi
        fi
    done
    # Trim leading space
    export NVCC_GENCODE="${NVCC_GENCODE# }"
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

make -j${CPU_COUNT} src.lib

make install PREFIX="${PREFIX}"

# Delete static library
rm "${PREFIX}/lib/libnccl_static.a"
