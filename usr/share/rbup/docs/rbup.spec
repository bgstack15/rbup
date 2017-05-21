# ref: http://www.rpm.org/max-rpm/s1-rpm-build-creating-spec-file.html
Summary:	rbup for EL7
Name:		rbup
Version:	0.0
Release:	1
License:	CC BY-SA 4.0
Group:		Applications/System
Source:		rbup.tgz
URL:		https://bgstack15.wordpress.com/
#Distribution:
#Vendor:
Packager:	B Stack <bgstack15@gmail.com>
Requires:	bgscripts-core >= 1.2-10
Buildarch:	noarch

%description
rbup is a shell script for conducting regular backups. It provides features such as auto-mount and dismount of the destination location.

%prep
%setup

%build

%install
rm -rf %{buildroot}
rsync -a . %{buildroot}/ --exclude='**/.*.swp' --exclude='**/.git'

%clean
rm -rf %{buildroot}

%preun
exit 0

%postun
exit 0

%post
exit 0

%files

%changelog
* Sun May 21 2017 B Stack <bgstack15@gmail.com> 0.0-1
- Initial rpm release. See docs/README.txt.
