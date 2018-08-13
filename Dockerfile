FROM ubuntu:16.04

USER root


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        cmake \
        git \
        libgoogle-glog-dev \
        libgtest-dev \
        libiomp-dev \
        libleveldb-dev \
        liblmdb-dev \
        libopencv-dev \
        libopenmpi-dev \
        libsnappy-dev \
        libprotobuf-dev \
        openmpi-bin \
        openmpi-doc \
        protobuf-compiler \
        libgflags-dev \
        python3-dev \
        python3-pip \
        python3-virtualenv \
        python3-setuptools \
        python3-wheel \
        python3-yaml \
      && \
      apt-get clean autoclean && \
      apt-get autoremove --yes && \
      rm -rf /var/lib/{apt,dpkg,cache,log}/


RUN pip3 install --user --no-cache-dir \
        future \
        numpy \
        protobuf

RUN git clone --recursive https://github.com/pytorch/pytorch.git && \
    cd pytorch && \
    git submodule update --init && \
    PYTORCH_PYTHON=/usr/bin/python3.5 \
    CMAKE_ARGS="-DCMAKE_BUILD_TYPE=Release -DUSE_CUDA=off" \
    python3 setup_caffe2.py bdist_wheel && \
    cp dist/*.whl / && \
    cd .. && rm -rf pytorch

RUN git clone https://github.com/onnx/onnx.git && \
    cd onnx && \
    git submodule update --init && \
    python3 setup.py bdist_wheel && \
    cp dist/*.whl / && \
    cd .. && rm -rf onnx

RUN pip3 install /*.whl && \
    python3 -c 'import caffe2.python.onnx.backend' # should show only warning about GPU support
