FROM ubuntu
MAINTAINER Sergey Novikov <snovikov@mirantis.com> && \
           Dmitry Kalashnik <dkalashnik@mirantis.com>
COPY . /tmp/rpm_builder
RUN apt-get update && apt-get install git wget rpm make gcc lrzip -y

RUN /bin/bash -c "mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}"        && \
    git clone http://github.com/dkalashnik/rallyd                                  && \

    lrzip -D -o /root/rpmbuild/SOURCES/rallyd.tar.lrz /tmp/rpm_builder/rallyd.tar  && \
    lrztar rallyd/rallyd-client && mv rallyd-client.tar.lrz /root/rpmbuild/SOURCES && \

    cp /tmp/rpm_builder/rally-docker.spec /root/rpmbuild/SPECS/rally-docker.spec   &&\
    cd /root/rpmbuild/ && rpmbuild -ba SPECS/rally-docker.spec
WORKDIR /root
USER root
