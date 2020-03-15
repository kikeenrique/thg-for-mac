#!/bin/zsh

set -euo pipefail

. toolchain/build_settings.conf
. toolchain/app_output_config.conf

NAME="mercurial"
VERSION="${HG_VERSION}"
VERIFY_FILE="${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/bin/hg"
DOWNLOAD_ADDR="https://www.mercurial-scm.org/release/${NAME}-${VERSION}.tar.gz"
DOWNLOAD_FILE="${DOWNLOADDIR}/${NAME}-${VERSION}.tar.gz"

if [ ! -L $VERIFY_FILE ]; then

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

  python setup.py clean
  python setup.py build
  python setup.py install

  cd $ROOT_DIR

else
  echo "${NAME} already installed."
fi
