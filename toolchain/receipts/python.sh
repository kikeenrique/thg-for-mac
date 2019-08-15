#!/bin/sh -xv

. toolchain/build_settings.conf

NAME="Python"
VERSION="2.7.16"
VERIFY_FILE=${DISTDIR}/usr/bin/python
DOWNLOAD_ADDR=https://www.python.org/ftp/python/${VERSION}/${NAME}-${VERSION}.tar.xz
DOWNLOAD_FILE=${DOWNLOADDIR}/${NAME}-${VERSION}.tar.xz

echo ${VERIFY_FILE}
if [ ! -L ${VERIFY_FILE} ]; then

  if [ ! -f $DOWNLOAD_FILE ]; then
    echo "Downloading ${DOWNLOAD_ADDR}"
    curl -L $DOWNLOAD_ADDR --output ${DOWNLOAD_FILE}
  fi

  rm -rf ${BUILDDIR}/${NAME}-${VERSION}
  mkdir -p toolchain/build

  if [ ! -d ${BUILDDIR}/${NAME}-${VERSION} ]; then
    echo "Extracting ${DOWNLOAD_FILE}"
    cd toolchain/build
    tar -xf ${DOWNLOAD_FILE}
    cd ${NAME}-${VERSION}
  else
    cd ${BUILDDIR}/${NAME}-${VERSION}
  fi

  export CC="clang"
  export CXX="clang++"
  export CFLAGS="-Os -pipe -fno-common -fno-strict-aliasing -fwrapv -DENABLE_DTRACE -DMACOSX -DNDEBUG -I${DISTDIR}/usr/include -I${SDKROOT}/usr/include"
  export LDFLAGS="-L${DISTDIR}/usr/lib"

  ./configure \
    --prefix="${DISTDIR}/usr" \
    --mandir="${DISTDIR}/usr/share/man" \
    --infodir="${DISTDIR}/usr/share/info" \
    --enable-ipv6 \
    --with-threads \
    --enable-framework="${DISTDIR}/System/Library/Frameworks" \
    --enable-toolbox-glue \
    --enable-optimizations 

  make ${MAKE_JOBS}
  make install

  cd $ROOT_DIR
else
  echo "Python installation found."
  export LDFLAGS="-L${DISTDIR}/usr/lib"
fi
