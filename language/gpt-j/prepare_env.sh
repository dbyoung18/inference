#!/bin/bash

set -x

WORK_DIR=$PWD

echo '==> Create Conda Environment'
conda create -n gptj python=3.9 -y
conda activate gptj
conda install mkl mkl-include -y
conda install gperftools jemalloc==5.2.1 -c conda-forge -y

echo '==> Install PyTorch'
# you can find other nightly version in https://download.pytorch.org/whl/nightly/
pip install https://download.pytorch.org/whl/nightly/cpu-cxx11-abi/torch-2.0.0.dev20230228%2Bcpu.cxx11.abi-cp39-cp39-linux_x86_64.whl

echo '==> Install Dependencies'
pip install transformers datasets evaluate accelerate simplejson nltk rouge_score

echo '==> Setup Environment Variables'
export KMP_BLOCKTIME=1
export KMP_SETTINGS=1
export KMP_AFFINITY=granularity=fine,compact,1,0
# IOMP
export LD_PRELOAD=${LD_PRELOAD}:${CONDA_PREFIX}/lib/libiomp5.so
# Tcmalloc is a recommended malloc implementation that emphasizes fragmentation avoidance and scalable concurrency support.
export LD_PRELOAD=${LD_PRELOAD}:${CONDA_PREFIX}/lib/libtcmalloc.so

echo '==> Build Loagen'
git clone --recurse-submodules https://github.com/mlcommons/inference.git mlperf_inference
cd mlperf_inference/loadgen
CFLAGS="-std=c++14 -O3" python setup.py bdist_wheel
cd ..; pip install --force-reinstall loadgen/dist/`ls -r loadgen/dist/ | head -n1` ; cd -
cd ../..

set +x

