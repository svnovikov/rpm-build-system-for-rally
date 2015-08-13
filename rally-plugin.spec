Name:    rally
Summary:  Rally Docker image
Version: 0.0.4
Release: 0
License:   Apache 2.0
BuildArch: noarch
BuildRoot: /root/rpmbuild/BUILDROOT
Source0:   rallyd.tar.lrz
URL:       http://mirantis.com
Requires:  docker-io
Requires:  lrzip
%description
Imports docker container with Rally into docker on master

%prep
rm -rf %{name}-%{version}
mkdir %{name}-%{version}
cp %{SOURCE0} %{name}-%{version}

%install
cd %{name}-%{version}
mkdir -p $RPM_BUILD_ROOT/tmp
cp rallyd.tar.lrz $RPM_BUILD_ROOT/tmp/
cd $RPM_BUILD_ROOT/tmp/
lrztar -d rallyd.tar.lrz
cd

%post
docker load < /tmp/rallyd/rallyd.tar

%clean
rm -rf %{name}-buildroot

%files
/tmp/rallyd.tar.lrz
/tmp/rallyd/rallyd.tar
/tmp/rallyd/rallyd-client.py
/tmp/rallyd/rallyd-client.pyc
/tmp/rallyd/rallyd-client.pyo
