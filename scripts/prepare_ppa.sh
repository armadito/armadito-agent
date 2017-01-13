#!/bin/bash

OPT=$1

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ROOTDIR=$DIR/../
TARBALL_VERSION=$(cat $ROOTDIR/version)
BUILD_VERSION=$1

cd $ROOTDIR

#EMAIL=vhamon@teclib.com dh-make-perl refresh -o control,docs,example,rules --requiredeps
rm -rf $ROOTDIR/out

set -e
$ROOTDIR/scripts/deb-src.sh -d xenial -k EB623C6B -v $BUILD_VERSION -D $ROOTDIR/out/ $ROOTDIR/libarmadito-agent-perl-$TARBALL_VERSION.tar.gz

# ===================
# dput -u ppa:armadito/armadito-agent $BUILD_DIR/${PKG}_${DEBIAN_VERSION}${BUILD_VERSION}~${DISTRIB}_source.changes
