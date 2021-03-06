#!/bin/zsh

set -euo pipefail

. toolchain/build_settings.conf

NAME="PyQt5"
VERSION="5.13.2"
VERIFY_FILE="${DISTDIR}/usr/bin/pyuic5"
DOWNLOAD_ADDR="https://www.riverbankcomputing.com/static/Downloads/PyQt5/${VERSION}/${NAME}-${VERSION}.tar.gz"
DOWNLOAD_FILE="${DOWNLOADDIR}/${NAME}-${VERSION}.tar.gz"

if [ ! -f $VERIFY_FILE ]; then

  if [ ! -f $DOWNLOAD_FILE ]; then
    echo "Downloading ${DOWNLOAD_ADDR}"
    curl -L $DOWNLOAD_ADDR --output ${DOWNLOAD_FILE}
  fi

  rm -rf ${BUILDDIR}/${NAME}-${VERSION}
  mkdir -p ${BUILDDIR}

  if [ ! -d ${BUILDDIR}/${NAME}-${VERSION} ]; then
    echo "Extracting ${DOWNLOAD_FILE}"
    cd ${BUILDDIR}
    tar -xf ${DOWNLOAD_FILE}
    cd ${NAME}-${VERSION}
  else
    cd ${BUILDDIR}/${NAME}-${VERSION}
  fi

  python3 configure.py --help
  python3 configure.py \
    --bindir=${DISTDIR}/usr/bin \
    --confirm-license \
    --verbose

  make ${MAKE_JOBS}
  make install

  rm -rf "${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python3.7/site-packages/PyQt5/uic/port_v2"
  cd $ROOT_DIR
else
  echo "${NAME} already installed."
fi
