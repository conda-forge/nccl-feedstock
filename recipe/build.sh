#!/bin/bash

make -j${CPU_COUNT} src.lib CUDA_HOME="${CUDA_HOME}" CUDARTLIB="cudart"
make install PREFIX="${PREFIX}"
