Name:    rally
Summary:  Rally Docker image
Version: 0.0.4
Release: 0
License:   Apache 2.0
BuildArch: noarch
BuildRoot: /root/rpmbuild/BUILDROOT
Source0:   rally.tar.lrz
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
cp rally.tar.lrz $RPM_BUILD_ROOT/tmp/
cd $RPM_BUILD_ROOT/tmp/
lrztar -d rally.tar.lrz
cd

%post
docker load < /tmp/rally/fuel-rally.tar
cp /tmp/rally/rally.py /usr/local/bin/rally
chmod +x /usr/local/bin/rally

%clean
rm -rf %{name}-buildroot

%files
/tmp/rally.tar.lrz
/tmp/rally/fuel-rally.tar
/tmp/rally/rally.py
/tmp/rally/rally.pyc
/tmp/rally/rally.pyo
