FROM jupyter/all-spark-notebook
MAINTAINER Yu-Hsin Lu <kerol2r20@gmail.com>

RUN rm -rf /home/*

CMD ["jupyterhub"]