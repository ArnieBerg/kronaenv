# base img
FROM condaforge/mambaforge:4.12.0-0

# install basic dependencies
RUN apt-get update && \
    apt-get install -y curl wget && \
    rm -rf /var/lib/apt/lists/*

RUN addgroup --gid 1000 docker && \
    adduser --uid 1000 --ingroup docker --home /home/docker --shell /bin/sh --disabled-password --gecos "" docker

# add yaml config to /conf
ADD conda/ /conf/

# create a conda env for each yaml config
RUN CONDA_DIR="/opt/conda" && \
    for file in $(ls /conf); do mamba env create --file /conf/$file; done

# clean up unused and cached pkgs
RUN CONDA_DIR="/opt/conda" && \
    mamba clean --all --yes && \
    rm -rf $CONDA_DIR/conda-meta && \
    rm -rf $CONDA_DIR/include && \
    rm -rf $CONDA_DIR/lib/python3.*/site-packages/pip && \
    find $CONDA_DIR -name '__pycache__' -type d -exec rm -rf '{}' '+'