#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
export LC_ALL=C
mkdir -p build/linux deliverables
gcc -std=c11 -Wall -Wextra -Werror -O2 -o build/linux/helloworld src/linux/helloworld.c
test "$(build/linux/helloworld)" = 'Hello, World from Joey_Saade!'
stage=build/linux/deb
mkdir -p "$stage/DEBIAN" "$stage/usr/local/bin" "$stage/usr/share/doc/helloworld-joey-saade"
install -m 0755 build/linux/helloworld "$stage/usr/local/bin/helloworld"
install -m 0644 docs/README.md docs/help.txt docs/user_guide.txt "$stage/usr/share/doc/helloworld-joey-saade/"
install -m 0644 packaging/debian/control "$stage/DEBIAN/control"
dpkg-deb --root-owner-group --build "$stage" deliverables/helloworld_joey_saade.deb
dpkg-deb --info deliverables/helloworld_joey_saade.deb
dpkg-deb --contents deliverables/helloworld_joey_saade.deb
topdir="$(pwd)/build/rpmbuild"
source=helloworld-joey-saade-1.0.0
mkdir -p "$topdir/BUILD" "$topdir/RPMS" "$topdir/SOURCES/$source" "$topdir/SPECS" "$topdir/SRPMS" "$topdir/BUILDROOT"
install -m 0755 build/linux/helloworld "$topdir/SOURCES/$source/helloworld"
install -m 0644 docs/README.md docs/help.txt docs/user_guide.txt "$topdir/SOURCES/$source/"
tar -czf "$topdir/SOURCES/$source.tar.gz" -C "$topdir/SOURCES" "$source"
rpmbuild --define "_topdir $topdir" --define '_build_id_links none' -ba packaging/rpm/helloworld.spec
cp "$topdir/RPMS/x86_64/helloworld-joey-saade-1.0.0-1.x86_64.rpm" deliverables/helloworld_joey_saade.rpm
cp "$topdir/SRPMS/helloworld-joey-saade-1.0.0-1.src.rpm" deliverables/helloworld_joey_saade.src.rpm
rpm -qip deliverables/helloworld_joey_saade.rpm
rpm -qlp deliverables/helloworld_joey_saade.rpm
