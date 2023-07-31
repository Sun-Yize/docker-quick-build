FROM yizesun/pytorch-env:pytorch-cuda-env
# Tensorflow Package version passed as build argument e.g. --build-arg TF_VERSION=2.9.2
# A blank value will install the latest version
ARG TF_VERSION=
# Install packages inside the new environment
RUN pip install --upgrade --no-cache-dir tensorflow${TF_VERSION:+==${TF_VERSION}} && pip cache purge
