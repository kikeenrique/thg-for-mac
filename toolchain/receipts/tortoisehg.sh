#!/bin/zsh

set -euo pipefail

. toolchain/build_settings.conf
. toolchain/app_output_config.conf

NAME="tortoisehg"
VERSION="${THG_VERSION}"
VERIFY_FILE="${DISTDIR}/${NAME}-${VERSION}/thg"
DOWNLOAD_ADDR="https://bitbucket.org/tortoisehg/thg/get/${VERSION}.tar.gz"
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
    # need to cd into folder like this beacuse it's not possible to extract a pattern: tortoisehg-thg-89b2d1787506
    mv ${NAME}* ${NAME}-${VERSION}
    cd ${NAME}-${VERSION}
  else
    cd ${BUILDDIR}/${NAME}-${VERSION}
  fi

  python3 setup.py clean
  python3 setup.py build
  python3 setup.py install

  cd $ROOT_DIR

else
  echo "${NAME} already installed."
fi
