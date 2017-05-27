FROM debian:jessie
MAINTAINER Yu-Hsin Lu <jupyter@googlegroups.com>

# install nodejs, utf8 locale, set CDN because default httpredir is unreliable
ENV DEBIAN_FRONTEND noninteractive
RUN REPO=http://cdn-fastly.deb.debian.org && \
    echo "deb $REPO/debian jessie main\ndeb $REPO/debian-security jessie/updates main" > /etc/apt/sources.list && \
    apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install wget locales git bzip2 &&\
    /usr/sbin/update-locale LANG=C.UTF-8 && \
    locale-gen C.UTF-8 && \
    apt-get remove -y locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV LANG C.UTF-8

# install Python + NodeJS with conda
RUN ANACONDA_URL="https://repo.continuum.io/archive" && \
    ANACONDA_FILENAME="Anaconda3-4.3.1-Linux-x86_64.sh" && \
    wget -q "$ANACONDA_URL/$ANACONDA_FILENAME" -O /tmp/anaconda.sh  && \
    bash /tmp/anaconda.sh -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes -c conda-forge sqlalchemy tornado jinja2 traitlets requests pip nodejs configurable-http-proxy && \
    /opt/conda/bin/pip install --upgrade pip && \
    rm /tmp/anaconda.sh && \
    git clone https://github.com/jupyterhub/jupyterhub /src/jupyterhub
ENV PATH=/opt/conda/bin:$PATH

WORKDIR /src/jupyterhub

RUN python setup.py js && pip install . && \
    rm -rf $PWD ~/.cache ~/.npm

RUN mkdir -p /srv/jupyterhub/
WORKDIR /srv/jupyterhub/
EXPOSE 8000

LABEL org.jupyter.service="jupyterhub"

CMD ["jupyterhub"]