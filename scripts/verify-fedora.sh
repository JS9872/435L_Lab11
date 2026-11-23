#!/bin/sh
set -eu
export LC_ALL=C
cd /work
rpm -ivh deliverables/helloworld_joey_saade.rpm
rpm -qi helloworld-joey-saade
rpm -ql helloworld-joey-saade
test "$(/usr/local/bin/helloworld)" = 'Hello, World from Joey_Saade!'
/usr/local/bin/helloworld
for document in README.md help.txt user_guide.txt; do
    expected=$(sha256sum "docs/$document" | cut -d ' ' -f 1)
    actual=$(sha256sum "/usr/share/doc/helloworld-joey-saade/$document" | cut -d ' ' -f 1)
    test "$expected" = "$actual"
done
rpm -V helloworld-joey-saade
rpm -e helloworld-joey-saade
test ! -e /usr/local/bin/helloworld
rpm -ivh deliverables/helloworld_joey_saade.rpm
echo 'PASS: RPM installation, output, documentation, integrity, removal and reinstall'
