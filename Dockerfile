FROM centos
MAINTAINER Sergey Novikov <snovikov@mirantis.com>
COPY . /tmp/rpm_builder
RUN yum install git wget -y 
RUN cd /tmp/                                                                              && \
    wget https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm     && \
    rpm -ivh epel-release-7-5.noarch.rpm
RUN yum install rpm-build redhat-rpm-config make gcc lrzip -y
RUN git clone https://github.com/dkalashnik/rallyd  
RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}                              && \
    mkdir /root/rpmbuild/SOURCES/rallyd                                                   && \
    cp /tmp/rpm_builder/rallyd.tar /root/rpmbuild/SOURCES/rallyd/rallyd.tar               && \
    cp /rallyd/rallyd-client.py /root/rpmbuild/SOURCES/rallyd/rallyd-client.py            && \
    cd /root/rpmbuild/SOURCES/ && lrztar rallyd                                           && \
    cp /tmp/rpm_builder/rally-plugin.spec /root/rpmbuild/SPECS/rally-plugin.spec          && \
    cd /root/rpmbuild/ && rpmbuild -ba SPECS/rally-plugin.spec                            && \
    rm -rf /tmp/*      
WORKDIR /root
USER root 
