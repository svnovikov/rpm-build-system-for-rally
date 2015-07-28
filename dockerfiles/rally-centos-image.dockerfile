FROM fuel/centos
MAINTAINER Sergey Novikov <snovikov@mirantis.com> Dmitry Kalashnik <dkalashnik@mirantis.com>
COPY . /tmp/rally
RUN yum install -y wget
RUN cd /tmp/                                                                                && \
    wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm    && \
    rpm -ivh epel-release-6-8.noarch.rpm
#RUN yum -y update
RUN yum groupinstall "Development tools" -y                                                 && \
    yum install -y zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel          && \
    cd /tmp                                                                                 && \
    wget --no-check-certificate https://www.python.org/ftp/python/2.7.6/Python-2.7.6.tar.xz && \
    tar xf Python-2.7.6.tar.xz                                                              && \
    cd Python-2.7.6                                                                         && \
    ./configure --prefix=/usr/local                                                         && \
    make && make altinstall                                                                 && \
    ln -s /usr/local/bin/python2.7 /usr/local/bin/python                                    && \
    cd /tmp                                                                                 && \
    wget https://bitbucket.org/pypa/setuptools/raw/bootstrap/ez_setup.py                    && \
    /usr/local/bin/python2.7 ez_setup.py                                                    && \
    /usr/local/bin/easy_install-2.7 pip                                                     && \
    mv /usr/local/bin/pip /usr/local/bin/pip2.6                                             && \
    mv /usr/local/bin/easy_install /usr/local/bin/easy_install-2.6                          && \
    ln -s /usr/local/bin/pip2.7 /usr/local/bin/pip                                          && \
    ln -s /usr/local/bin/easy_install-2.7 /usr/local/bin/easy_install                       
RUN cp /tmp/rally/start.sh /usr/local/bin/start.sh                                          && \
    chmod +x /usr/local/bin/start.sh
RUN yum erase -y postgresql.x86_64 postgresql-libs.x86_64 postgresql-server.x86_64
RUN yum -y install git bash-completion python-devel libffi-devel libxml2-devel                 \
    gcc libxslt-devel openssl-devel gmp-devel postgresql-devel
RUN cd /tmp/                                                                                && \
    wget http://dl.fedoraproject.org/pub/epel/6/x86_64/sshpass-1.05-1.el6.x86_64.rpm        && \
    rpm -ivh sshpass-1.05-1.el6.x86_64.rpm
RUN yum install -y uuid-devel pkgconfig libtool gcc-c++                                     && \
    cd /tmp/                                                                                && \
    git clone https://github.com/stackforge/haos.git                                        && \
    pip install -r haos/requirements.txt && pip install -r haos/test-requirements.txt 
RUN cd /tmp/                                                                                && \
    cp haos/patches/01-rally-plugin-dir.patch /tmp/rally/01-rally-plugin-dir.patch          && \
    cp haos/patches/02-rally-no-postgresql.patch /tmp/rally/02-rally-no-postgresql.patch    && \ 
    cd /tmp/rally                                                                           && \
    patch -p1 < 01-rally-plugin-dir.patch                                                   && \
    patch -p1 < 02-rally-no-postgresql.patch
RUN cd /tmp                                                                                 && \
    wget https://raw.github.com/pypa/pip/master/contrib/get-pip.py -O /tmp/pip.py           && \
    python /tmp/pip.py && rm /tmp/pip.py                                                    && \
    cd /tmp/rally                                                                           && \
    ./install_rally.sh                                                                      && \
    pip install -r optional-requirements.txt                                                && \
    sed 's|#*connection *=.*|connection = sqlite:////var/lib/rally/database/rally.sqlite|'     \
        -i /etc/rally/rally.conf                                                            && \
    mv doc /usr/share/doc/rally                                                             && \
    update-alternatives --install /usr/bin/python python /usr/bin/python2.7 10              && \
    ln -s /usr/share/doc/rally /root/rally-docs
RUN cd /tmp/haos/                                                                           && \
    python setup.py install     
RUN rm -fr /tmp/*                                                                           && \
    rm -rf /var/lib/apt/lists/*                                                             
USER root
CMD bash --login
ENV HOME /root
WORKDIR /root
