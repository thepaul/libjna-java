#!/bin/sh

if [ $# -ne 3 ]
then
    echo "Usage: $0 option version filename"
    echo "If option=--upstream-version, run uupdate after repacking sources."
    echo "Filename is never used, as uscan will always download the wrong file."
    exit
fi

VERSION=$2

CURDIR=$(pwd)
TMPDIR=`mktemp -d libjna-tmp.XXXXXX`
BASEDIR=$TMPDIR/libjna-java-${VERSION}
mkdir ${BASEDIR}

# retrieve sources from svn
# svn export https://jna.dev.java.net/svn/jna/tags/${VERSION}/jnalib/ --username guest ${BASEDIR}
wget --user guest --password "" \
      --directory-prefix=${TMPDIR} \
      https://jna.dev.java.net/svn/jna/tags/${VERSION}/jnalib/pom.xml \
      https://jna.dev.java.net/svn/jna/tags/${VERSION}/jnalib/dist/src.zip \
      https://jna.dev.java.net/svn/jna/tags/${VERSION}/jnalib/src/com/sun/jna/overview.html \
      https://jna.dev.java.net/svn/jna/tags/${VERSION}/jnalib/src/com/sun/jna/package.html

unzip -d ${BASEDIR} ${TMPDIR}/src.zip

# remove jar files
rm -rf ${BASEDIR}/lib

# remove libffi
rm -rf ${BASEDIR}/native/libffi

# files missing in src.zip
mv ${TMPDIR}/*html ${BASEDIR}/src/com/sun/jna/
mv ${TMPDIR}/*xml ${BASEDIR}/

# Repack
GZIP=-9 tar -C "$TMPDIR" -czf ../libjna-java_${VERSION}.orig.tar.gz "libjna-java-${VERSION}"

# Clean temporary files
rm -rf "$TMPDIR"
rm -rf "$BASEDIR"
rm -f "$FILENAME"

if [ $1 = --upstream-version ] ;
then
    uupdate --upstream-version $2 $3
fi
