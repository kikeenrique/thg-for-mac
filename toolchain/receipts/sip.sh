#!/bin/zsh

set -euo pipefail

. toolchain/build_settings.conf

NAME="sip"
VERSION="4.19.20"
VERIFY_FILE="${DISTDIR}/usr/bin/sip"
DOWNLOAD_ADDR="https://www.riverbankcomputing.com/static/Downloads/sip/${VERSION}/${NAME}-${VERSION}.tar.gz"
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

  #sed -i '' 's/PyStringCheck/PyString_Check/g' siplib/siplib.c

  # PyQt5.11 and later needs `--sip-module PyQt5.sip`
  # https://stackoverflow.com/a/57381325
  python3 configure.py --bindir=${DISTDIR}/usr/bin --sip-module PyQt5.sip
  make ${MAKE_JOBS}
  make install

  cd $ROOT_DIR
else
  echo "${NAME} already installed."
fi
