ARG CUDA_VER=11.8.0
ARG UBUNTU_VER=22.04
# Download the base image
FROM nvidia/cuda:${CUDA_VER}-cudnn8-runtime-ubuntu${UBUNTU_VER}
# you can check for all available images at https://hub.docker.com/r/nvidia/cuda/tags

# Install as root
USER root

# Shell
SHELL ["/bin/bash", "--login", "-o", "pipefail", "-c"]

# miniconda path
ENV CONDA_DIR /opt/miniconda

# conda path
ENV PATH=${CONDA_DIR}/bin:$PATH

ARG DEBIAN_FRONTEND="noninteractive"
ARG USERNAME=charlie
ARG USERID=1000
ARG GROUPID=1000

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    bash-completion \
    ca-certificates \
    curl \
    git \
    htop \
    nano \
    nvidia-modprobe \
    openssh-client \
    sudo \
    tmux \
    unzip \
    vim \
    wget \ 
    zip && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Expose port 8000 for code-server
EXPOSE 8000

# Install miniconda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh && \
    /bin/bash miniconda.sh -b -p ${CONDA_DIR} && \
    rm -rf miniconda.sh && \
    # Enable conda autocomplete
    sudo wget --quiet https://github.com/tartansandal/conda-bash-completion/raw/master/conda -P /etc/bash_completion.d/

WORKDIR /root/

# Initilize shell for conda
RUN conda init bash && source .bashrc
# create conda env
RUN conda create -n dl python=3.9
SHELL ["conda", "run", "-n", "dl", "/bin/bash", "-c"]

# install python packages
RUN pip install \
    ipywidgets \
    jupyterlab \
    matplotlib \
    nltk \
    notebook \
    numpy \
    pandas \
    Pillow \
    plotly \
    PyYAML \
    scipy \
    scikit-image \
    scikit-learn \
    sympy \
    seaborn \
    tqdm \
    jupyter

# install pytorch
RUN pip install --upgrade --no-cache-dir torch torchvision torchaudio torchtext torchserve --extra-index-url https://download.pytorch.org/whl/nightly/cu118 && \
    pip install --upgrade --no-cache-dir lightning && \
    pip cache purge

# git clone
RUN git clone https://github.com/AI4Finance-Foundation/FinRL.git
RUN git clone https://github.com/AI4Finance-Foundation/FinGPT.git
RUN git clone https://github.com/facebookresearch/llama-recipes.git
RUN cd llama-recipes && git clone https://github.com/huggingface/transformers.git && \
    cd transformers && pip install protobuf
RUN curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash

# install git lfs
RUN sudo apt-get install git-lfs
RUN git lfs install

RUN pip install transformers datasets accelerate sentencepiece protobuf==3.20 py7zr scipy peft bitsandbytes fire torch_tb_profiler ipywidgets
RUN cd llama-recipes && pip install -r requirements.txt

# install gdrive
RUN wget https://github.com/glotlabs/gdrive/releases/download/3.9.0/gdrive_linux-x64.tar.gz && \
    tar -xf gdrive_linux-x64.tar.gz && \
    rm gdrive_linux-x64.tar.gz
COPY private/gdrive_export-inifyy_gmail_com.tar /root/
# add personal account
RUN /root/gdrive account import gdrive_export-inifyy_gmail_com.tar
