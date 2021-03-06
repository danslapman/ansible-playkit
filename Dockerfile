FROM ubuntu:16.04
MAINTAINER Oleg Poyaganov <oleg@poyaganov.com>

RUN apt-get -y update && \
    apt-get install -y build-essential libssl-dev libffi-dev python-dev python-yaml python-jinja2 python-httplib2 python-keyczar python-paramiko python-setuptools python-pkg-resources git curl && \
    curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py" && \
    python get-pip.py && \
    rm get-pip.py &&\
    apt-get clean autoclean && \
    apt-get autoremove -y && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/

ADD . /opt/src

RUN cd /opt/src && \
    python setup.py install && \
    rm -rf /opt/src && \
    cd / && \
    pip uninstall -y ansible && \
    mkdir /etc/ansible/ && \
    echo '[local]\nlocalhost\n' > /etc/ansible/hosts && \
    mkdir /opt/ansible/ && \
    git clone --branch stable-2.2 --depth 1 https://github.com/ansible/ansible.git /opt/ansible/ansible && \
    cd /opt/ansible/ansible && \
    git submodule update --init --recursive && \
    make && make install && \
    mkdir -p /work

VOLUME ["/work"]

ENV PATH /opt/ansible/ansible/bin:/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
ENV PYTHONPATH /opt/ansible/ansible/lib
ENV ANSIBLE_LIBRARY /opt/ansible/ansible/library

WORKDIR /work

ENTRYPOINT ["ansible-playkit"]
