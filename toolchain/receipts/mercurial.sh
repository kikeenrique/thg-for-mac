#!/bin/sh

. toolchain/build_settings.conf

NAME="mercurial"
VERSION="4.9.1"
VERIFY_FILE="$DISTDIR/usr/bin/hg"
DOWNLOAD_ADDR="https://www.mercurial-scm.org/release/${NAME}-${VERSION}.tar.gz"
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

  python setup.py clean
  python setup.py build
  python setup.py install

  cd $ROOT_DIR

else
  echo "${NAME} already installed."
fi
