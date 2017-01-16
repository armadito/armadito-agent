#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$DIR/../
TARBALL_VERSION=$(cat $ROOTDIR/version)

set -e
cd $ROOTDIR
./do_all.sh

make dist
tar -xzf $ROOTDIR/Armadito-Agent-$TARBALL_VERSION.tar.gz
mv -f $ROOTDIR/Armadito-Agent-$TARBALL_VERSION $ROOTDIR/libarmadito-agent-perl-$TARBALL_VERSION
tar -czf $ROOTDIR/libarmadito-agent-perl-$TARBALL_VERSION.tar.gz $ROOTDIR/libarmadito-agent-perl-$TARBALL_VERSION

rm -rf $ROOTDIR/libarmadito-agent-perl-$TARBALL_VERSION
rm -rf $ROOTDIR/Armadito-Agent-$TARBALL_VERSION*
