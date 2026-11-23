#!/bin/sh
set -eu
cd /work
echo '$ rpmbuild --define "_topdir /work/build/rpmbuild" --define "_build_id_links none" -ba packaging/rpm/helloworld.spec'
rpmbuild --define '_topdir /work/build/rpmbuild' --define '_build_id_links none' -ba packaging/rpm/helloworld.spec > /tmp/lab11-rpm-build.log 2>&1
grep 'Wrote:' /tmp/lab11-rpm-build.log
cp build/rpmbuild/RPMS/x86_64/helloworld-joey-saade-1.0.0-1.x86_64.rpm deliverables/helloworld_joey_saade.rpm
cp build/rpmbuild/SRPMS/helloworld-joey-saade-1.0.0-1.src.rpm deliverables/helloworld_joey_saade.src.rpm
echo '$ rpm -qip deliverables/helloworld_joey_saade.rpm'
rpm -qip deliverables/helloworld_joey_saade.rpm
echo '$ rpm -qlp deliverables/helloworld_joey_saade.rpm'
rpm -qlp deliverables/helloworld_joey_saade.rpm
