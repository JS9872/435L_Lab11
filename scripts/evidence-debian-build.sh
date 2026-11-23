#!/bin/sh
set -eu
cd /work
echo '$ gcc -std=c11 -Wall -Wextra -Werror -O2 -o build/linux/helloworld src/linux/helloworld.c'
gcc -std=c11 -Wall -Wextra -Werror -O2 -o build/linux/helloworld src/linux/helloworld.c
echo '$ dpkg-deb --root-owner-group --build build/linux/deb deliverables/helloworld_joey_saade.deb'
dpkg-deb --root-owner-group --build build/linux/deb deliverables/helloworld_joey_saade.deb
echo '$ dpkg-deb -I deliverables/helloworld_joey_saade.deb'
dpkg-deb -I deliverables/helloworld_joey_saade.deb
echo '$ dpkg-deb -c deliverables/helloworld_joey_saade.deb'
dpkg-deb -c deliverables/helloworld_joey_saade.deb | grep -E 'helloworld$|README.md$|help.txt$|user_guide.txt$'
