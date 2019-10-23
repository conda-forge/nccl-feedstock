#!/bin/bash

make -j${CPU_COUNT} CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart"
make install PREFIX="${PREFIX}"
