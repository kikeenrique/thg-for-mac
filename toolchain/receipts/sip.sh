#!/bin/sh

. toolchain/build_settings.conf

NAME="sip"
VERSION="4.19.8"
VERIFY_FILE="$DISTDIR/usr/bin/sip"
DOWNLOAD_ADDR="http://sourceforge.net/projects/pyqt/files/sip/${NAME}-${VERSION}/${NAME}-${VERSION}.tar.gz"
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

  #sed -i '' 's/PyStringCheck/PyString_Check/g' siplib/siplib.c
  python configure.py --bindir=${DISTDIR}/usr/bin
  make ${MAKE_JOBS}
  make install

  cd $ROOT_DIR
else
  echo "${NAME} already installed."
fi
