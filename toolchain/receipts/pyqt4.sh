#!/bin/sh

. toolchain/build_settings.conf

NAME="PyQt4_gpl_mac"
VERSION="4.12.1"
VERIFY_FILE="$DISTDIR/usr/bin/pyuic4"
DOWNLOAD_ADDR="http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-${VERSION}/${NAME}-${VERSION}.tar.gz"
DOWNLOAD_FILE="${DOWNLOADDIR}/${NAME}-${VERSION}.tar.gz"

if [ ! -f $VERIFY_FILE ]; then

  if [ ! -f $DOWNLOAD_FILE ]; then
    echo "Downloading ${DOWNLOAD_ADDR}"
    curl -L $DOWNLOAD_ADDR --output ${DOWNLOAD_FILE}
  fi

  rm -rf toolchain/build/${NAME}-${VERSION}
  mkdir -p toolchain/build

  if [ ! -d toolchain/build/${NAME}-${VERSION} ]; then
    echo "Extracting ${DOWNLOAD_FILE}"
    cd toolchain/build
    tar -xf ${DOWNLOAD_FILE}
    cd ${NAME}-${VERSION}
  else
    cd toolchain/build/${NAME}-${VERSION}
  fi

  python configure.py --bindir=${DISTDIR}/usr/bin --confirm-license
  make ${MAKE_JOBS}
  make install

  rm -rf "${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages/PyQt4/uic/port_v3"
  cd $ROOT_DIR
else
  echo "${NAME} already installed."
fi
