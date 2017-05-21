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
%dir /etc/rbup
%dir /usr/share/rbup
%dir /usr/share/rbup/docs
%dir /usr/share/rbup/examples
%dir /usr/share/rbup/inc
%config %attr(666, -, -) /etc/rbup/rbup.conf.2017-05-21.01
%config %attr(666, -, -) /etc/rbup/rbup.conf
%doc %attr(444, -, -) /usr/share/rbup/docs/files-for-versioning.txt
/usr/share/rbup/docs/rbup.spec
%doc %attr(444, -, -) /usr/share/rbup/docs/README.txt
/usr/share/rbup/inc/get-files
/usr/share/rbup/inc/pack
/usr/share/rbup/rbup.sh
/usr/share/rbup/rbup.sh.2017-05-21.01
%verify(link) /usr/bin/rbup

%changelog
* Sun May 21 2017 B Stack <bgstack15@gmail.com> 0.0-1
- Initial rpm release. See docs/README.txt.
