#!/bin/sh
set -eu
export LC_ALL=C
cd /work
dpkg --path-include=/usr/share/doc/helloworld-joey-saade --path-include='/usr/share/doc/helloworld-joey-saade/*' -i deliverables/helloworld_joey_saade.deb
dpkg -l helloworld-joey-saade
dpkg -s helloworld-joey-saade
test "$(/usr/local/bin/helloworld)" = 'Hello, World from Joey_Saade!'
/usr/local/bin/helloworld
for document in README.md help.txt user_guide.txt; do
    cmp "docs/$document" "/usr/share/doc/helloworld-joey-saade/$document"
done
test -z "$(dpkg -V helloworld-joey-saade)"
dpkg -r helloworld-joey-saade
test ! -e /usr/local/bin/helloworld
dpkg --path-include=/usr/share/doc/helloworld-joey-saade --path-include='/usr/share/doc/helloworld-joey-saade/*' -i deliverables/helloworld_joey_saade.deb
echo 'PASS: DEB installation, output, documentation, integrity, removal and reinstall'
