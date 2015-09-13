Name:    rallyd-docker
Summary:  Rallyd Docker image
Version: 1.0.0
Release: 0
License:   Apache 2.0
BuildArch: noarch
BuildRoot: /root/rpmbuild/BUILDROOT
Source0:   rallyd.tar.lrz
Source1:   rallyd-client.tar.lrz
URL:       http://mirantis.com
Requires:  docker-io
Requires:  lrzip
%description
Imports docker container with Rally into docker on master and installs cilent

%prep
rm -rf %{name}-%{version}
mkdir %{name}-%{version}
cp %{SOURCE0} %{name}-%{version}
cp %{SOURCE1} %{name}-%{version}

%install
cd %{name}-%{version}
mkdir -p %{buildroot}/tmp
cp rallyd.tar.lrz %{buildroot}/tmp/
cp rallyd-client.tar.lrz %{buildroot}/tmp/

%clean
rm -rf %{buildroot}

%post
lrzip -d -o /tmp/rallyd.tar /tmp/rallyd.tar.lrz
docker load -i /tmp/rallyd.tar
cd /tmp && lrzuntar /tmp/rallyd-client.tar.lrz
pip install /tmp/rallyd/rallyd-client/

%files
/tmp/rallyd.tar.lrz
/tmp/rallyd-client.tar.lrz