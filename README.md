### Overview
rbup is a shell script for conducting regular backups. Originally its name meant rsync backup.

### Building
The recommended way to build an rpm is:

    pushd ~/rpmbuild; mkdir -p SOURCES RPMS SPECS BUILD BUILDROOT; popd
    mkdir -p ~/rpmbuild/SOURCES/rbup-0.0-1/
    cd ~/rpmbuild/SOURCES/rbup-0.0-1/
    git clone https://github.com/bgstack15/rbup
    usr/share/rbup/inc/pack rpm

The generated rpm will be in ~/rpmbuild/RPMS/noarch
