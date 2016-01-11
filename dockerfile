FROM debian:7.4

MAINTAINER Kamil Kwiek <kamil.kwiek@continuum.io>

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-2.4.1-Linux-x86_64.sh && \
    /bin/bash /Anaconda3-2.4.1-Linux-x86_64.sh -b -p /opt/conda && \
    rm /Anaconda3-2.4.1-Linux-x86_64.sh

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

ENV PATH /opt/conda/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

ENTRYPOINT [ "/usr/bin/tini", "--" ]
CMD [ "/bin/bash" ]

RUN mkdir -p /home/gensim_user/gensim
WORKDIR /home/gensim_user

RUN apt-get update && apt-get install -y wget build-essential python3-dev python3-setuptools python3-numpy python3-scipy python3-pip libatlas-dev libatlas3gf-base 
RUN wget -nv -O /tmp/gensim-0.12.3.tar.gz https://pypi.python.org/packages/source/g/gensim/gensim-0.12.3.tar.gz#md5=9581467d50ec6da0097939464c422d00 \
	&&	tar -xzvf /tmp/gensim-0.12.3.tar.gz -C /home/gensim_user/gensim --strip-components=1 \
	&&	cd /home/gensim_user/gensim \
	&&	python3 /home/gensim_user/gensim/setup.py install


