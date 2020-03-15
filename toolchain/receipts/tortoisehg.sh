#!/bin/zsh

set -euo pipefail

. toolchain/build_settings.conf
. toolchain/app_output_config.conf

NAME="tortoisehg"
VERSION="${THG_VERSION}"
VERIFY_FILE="${DISTDIR}/${NAME}-${VERSION}/thg"
DOWNLOAD_ADDR="https://bitbucket.org/tortoisehg/targz/downloads/${NAME}-${VERSION}.tar.gz"
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

  python setup.py clean
  python setup.py build
  python setup.py install

  cd $ROOT_DIR

else
  echo "${NAME} already installed."
fi
