FROM centos
MAINTAINER Sergey Novikov <snovikov@mirantis.com>
COPY . /tmp/rpm_builder
RUN yum install wget -y 
RUN cd /tmp/                                                                              && \
    wget https://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-5.noarch.rpm     && \
    rpm -ivh epel-release-7-5.noarch.rpm
RUN yum install rpm-build redhat-rpm-config make gcc lrzip -y
RUN mkdir -p /root/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}                              && \
    cp /tmp/rpm_builder/rpmmacros /root/.rpmmacros                                        && \
    mkdir /root/rpmbuild/SOURCES/rally                                                    && \
    cp /tmp/rpm_builder/fuel-rally.tar /root/rpmbuild/SOURCES/rally/fuel-rally.tar        && \
    cp /tmp/rpm_builder/rally.py /root/rpmbuild/SOURCES/rally/rally.py                    && \
    cd /root/rpmbuild/SOURCES/ && lrztar rally                                            && \
    cp /tmp/rpm_builder/spec /root/rpmbuild/SPECS/rally.spec                              && \
    cd /root/rpmbuild/ && rpmbuild -ba SPECS/rally.spec                                   && \
    rm -rf /tmp/*         
USER root
CMD bash --login
ENV HOME /root
WORKDIR /root 
