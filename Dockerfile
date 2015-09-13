FROM centos
MAINTAINER Sergey Novikov <snovikov@mirantis.com>
COPY . /tmp/rpm_builder

RUN yum install git wget -y

RUN cd /tmp/                                                                              && \
    wget https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm     && \
    rpm -ivh epel-release-7-5.noarch.rpm

RUN yum install rpm-build redhat-rpm-config make gcc lrzip -y

RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}                              && \
    git clone http://github.com/dkalashnik/rallyd                                         && \
    lrzip -D -o /root/rpmbuild/SOURCES/rallyd.tar.lrz /tmp/rpm_builder/rallyd.tar         && \
    lrztar rallyd/rallyd-client && mv rallyd-client.tar.lrz /root/rpmbuild/SOURCES        && \

    cp /tmp/rpm_builder/rally-docker.spec /root/rpmbuild/SPECS/rally-docker.spec          && \
    cd /root/rpmbuild/ && rpmbuild -ba SPECS/rally-docker.spec                            && \

    rm -rf /tmp/*

WORKDIR /root

USER root
