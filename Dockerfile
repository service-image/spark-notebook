FROM batazor/spark:2.0.2-rc1
MAINTAINER Victor Login <batazor111@gmail.com>

ENV CONDA_DIR /opt/conda
ENV PATH $CONDA_DIR/bin:$PATH
ENV ANACONDA_VERSION 4.2.0
ENV TINI_VERSION v0.13.0

# Install tini
RUN apt-get install -y curl grep sed dpkg && \
  TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
  curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
  dpkg -i tini.deb && \
  rm tini.deb && \
  apt-get clean

# Install anaconda
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda2-$ANACONDA_VERSION-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh
RUN $CONDA_DIR/bin/conda install jupyter -y --quiet && \
    mkdir /opt/notebooks

# Setting anaconda
ENV PYTHONPATH /usr/apache/spark-2.0.2-bin-hadoop2.7/python/lib/py4j-0.10.3-src.zip:/usr/apache/spark-2.0.2-bin-hadoop2.7/python:/usr/apache/spark-2.0.2-bin-hadoop2.7/python/build

# Other settings
ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888

VOLUME /opt/notebooks

# Run your program under Tini
CMD ["jupyter", "notebook", "--notebook-dir=/opt/notebooks", "--ip='*'", "--port=8888", "--no-browser"]
