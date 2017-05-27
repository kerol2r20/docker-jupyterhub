FROM alpine:edge

MAINTAINER Yu-Hsin Lu <kerol2r20@gmail.com>

# install pre-required packages
RUN apk update && \
    apk add --no-cache git wget bash ca-certificates build-base linux-pam-dev

# install GNU libc and set UTF-8 locale as default
RUN ALPINE_GLIBC_BASE_URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download" && \
    ALPINE_GLIBC_PACKAGE_VERSION="2.25-r0" && \
    ALPINE_GLIBC_BASE_PACKAGE_FILENAME="glibc-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_BIN_PACKAGE_FILENAME="glibc-bin-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    ALPINE_GLIBC_I18N_PACKAGE_FILENAME="glibc-i18n-$ALPINE_GLIBC_PACKAGE_VERSION.apk" && \
    wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://raw.githubusercontent.com/sgerrand/alpine-pkg-glibc/master/sgerrand.rsa.pub && \
    wget "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" -O "/tmp/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" && \
    wget "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" -O "/tmp/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" && \
    wget "$ALPINE_GLIBC_BASE_URL/$ALPINE_GLIBC_PACKAGE_VERSION/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" -O "/tmp/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    apk add "/tmp/$ALPINE_GLIBC_BASE_PACKAGE_FILENAME" "/tmp/$ALPINE_GLIBC_BIN_PACKAGE_FILENAME" "/tmp/$ALPINE_GLIBC_I18N_PACKAGE_FILENAME" && \
    /usr/glibc-compat/bin/localedef -i en_US -f UTF-8 en_US.UTF-8

# install miniconda
RUN MINICONDA_DOWNLOAD_URL="https://repo.continuum.io/miniconda" && \
    MINICONDA_FILENAME="Miniconda3-4.3.14-Linux-x86_64.sh" && \
    wget "$MINICONDA_DOWNLOAD_URL/$MINICONDA_FILENAME" -O "/tmp/$MINICONDA_FILENAME" && \
    bash "/tmp/$MINICONDA_FILENAME" -f -b -p /opt/conda && \
    /opt/conda/bin/conda install --yes -c conda-forge sqlalchemy tornado jinja2 traitlets requests pip nodejs configurable-http-proxy && \
    /opt/conda/bin/pip install --upgrade pip jupyter

ENV PATH=/opt/conda/bin:$PATH

# install jupyterhub
RUN git clone https://github.com/jupyterhub/jupyterhub /tmp/src/jupyterhub

WORKDIR /tmp/src/jupyterhub

RUN python setup.py js && pip install . && \
    rm -rf $PWD ~/.cache ~/.npm

RUN mkdir -p /srv/jupyterhub/

WORKDIR /srv/jupyterhub/

RUN jupyterhub --generate-config

EXPOSE 8000

CMD ["jupyterhub"]
