FROM rallyd-docker

MAINTAINER Sergey Novikov <snovikov@mirantis.com>                           && \
           Dmitry Kalashnik <dkalashnik@mirantis.com>

USER root

COPY . /tmp/mos_isolated

# Install deb dependencies
RUN apt-get update                                                          && \
    apt-get -y install build-essential gcc-4.8 libffi-dev libssl-dev           \
                       libxml2-dev libxslt1-dev python-dev python

# Install mos-nodes plugin
RUN git clone https://github.com/dkalashnik/

# Install local copy of tempest tag 6
RUN git config --global user.name "Rally User"                              && \
    git config --global user.email "rallyuser@rallyd.com"                   && \
    git clone https://github.com/openstack/tempest /opt/tempest             && \
    cd /opt/tempest && git checkout 6                                       && \
    pip install -r /opt/tempest/requirements.txt                               \
                -r /opt/tempest/test-requirements.txt

# Apply available pathes for rally and tempest
RUN cd /opt/tempest                                                         && \
    && git am /tmp/mos_isolated/tempest_patches/*                           && \
    cd /usr/local/lib/python2.7/dist-packages                               && \
    git apply /tmp/mos_isolated/rally_patches/*

# Setup haproxy and new startup script
RUN echo deb http://archive.ubuntu.com/ubuntu trusty-backports main universe | \
    tee /etc/apt/sources.list.d/backports.list                              && \
    apt-get update && apt-get install -y haproxy -t trusty-backports        && \
    cp /tmp/mos_isolated/haproxy.cfg.sample /etc/haproxy/haproxy.cfg        && \
    cp /tmp/mos_isolated/start_rallyd.sh /bin/start_rallyd                  && \
    chmod +x /bin/start_rallyd

CMD ["/bin/bash", "-c", "/bin/start_rallyd"]
