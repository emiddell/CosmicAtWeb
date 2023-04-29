FROM ubuntu:22.04

ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# install updates
RUN apt-get update && \
    apt-get upgrade -y &&  \
    apt-get -y install wget vim && \
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
RUN conda run -n ctplot --no-capture-output pip install -e .

WORKDIR /
CMD conda run -n ctplot --no-capture-output python /app/ctplot/webserver.py

#RUN conda install --yes seaborn basemap && conda clean --yes --tarballs
#RUN pip install https://github.com/quantenschaum/ctplot/archive/master.zip
#RUN conda run -n ctplot pip install https://github.com/mw10178/202211-mw/archive/refs/tags/2.4.0beta.0.zip

#RUN conda run -n ctplot pip install .
#WORKDIR /
#RUN adduser --disabled-password --gecos '' ctplot 
#USER ctplot 

#EXPOSE 8080
#CMD ["conda",  "run",  "-n ctplot",  "ctserver"]
#CMD conda run -n ctplot ctserver