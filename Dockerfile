FROM nvidia/cuda:10.2-devel-ubuntu16.04
# NOTE: build this image from dir above Dockerfile location
# USE BASH
SHELL ["/bin/bash", "-c"]

## modify below
ARG username=joe
ARG groupid=1000
ARG userid=1000
## end modify

# See http://bugs.python.org/issue19846
#ENV LANG C.UTF-8
#LABEL com.nvidia.volumes.needed="nvidia_driver"

#RUN echo "deb http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1604/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

RUN apt-get update && apt-get install -y --no-install-recommends \
         build-essential \
         cmake \
         git \
         curl \
         wget \
         vim \
         ca-certificates \
         python-qt4 \
         libjpeg-dev \
         zip \
         unzip \
         sudo \
         libpng-dev \
         libeigen3-dev \
         libgoogle-glog-dev=0.3.4-0.1 \
         libsuitesparse-dev=1:4.4.6-1 \
         libatlas-base-dev=3.10.2-9 &&\
     rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64
ENV PYTHON_VERSION=3.6.7

RUN curl -o ~/miniconda.sh -O  https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh  && \
     chmod +x ~/miniconda.sh && \
     ~/miniconda.sh -b -p /opt/conda && \
     rm ~/miniconda.sh && \
    /opt/conda/bin/conda install conda-build

ENV PATH=$PATH:/opt/conda/bin/
#ENV USER fastai
# Create Enviroment
COPY environment.yml /environment.yml
RUN conda env create -f environment.yml

#WORKDIR /notebooks
# Activate Source
#CMD source activate pvnet
#CMD source ~/.bashrc

# -m option creates a fake writable home folder for Jupyter.
RUN adduser --disabled-password --gecos '' $username \
    && adduser $username sudo \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $username

RUN cd /home/$username \
    && git clone https://github.com/jwdinius/pvnet.git \
    && cd pvnet \
    && chmod a+rwx build_ceres.sh \
    && ./build_ceres.sh /home/$username
RUN source activate pvnet \
    && cd /home/$username/pvnet/lib/ransac_voting_gpu_layer \
    && python setup.py build_ext --inplace
RUN source activate pvnet \
    && cd /home/$username/pvnet/lib/utils/extend_utils \
    && python build_extend_utils_cffi.py
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/$username/pvnet/lib/utils/extend_utils/lib

# Clone course-v3
#RUN git clone https://github.com/fastai/course-v3.git

#COPY config.yml /root/.fastai/config.yml
#COPY run.sh /run.sh

#CMD ["/run.sh"]
WORKDIR /home/$username
