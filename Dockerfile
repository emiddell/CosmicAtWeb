FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# install updates
RUN apt-get update && \
    apt-get upgrade -y &&  \
    apt-get -y install wget vim git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# install Miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/Miniconda3-latest-Linux-x86_64.sh &&\
    chmod +x /tmp/Miniconda3-latest-Linux-x86_64.sh && \
    /tmp/Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && \
    rm /tmp/Miniconda3-latest-Linux-x86_64.sh

ENV PATH /opt/miniconda3/bin:$PATH

# update base environment
RUN conda update --yes --all && conda clean --yes --tarballs

COPY conda_environment.yml /tmp/conda_environment.yml

# setup ctplot environment
RUN conda env create -f /tmp/conda_environment.yml && \
    rm /tmp/conda_environment.yml

# install application
WORKDIR /app
COPY . .

# install ctplot package
RUN conda run -n ctplot --no-capture-output pip install .

WORKDIR /
CMD conda run -n ctplot --no-capture-output python /app/ctplot/webserver.py