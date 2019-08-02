#/bin/bash

function log() {
    printf "+++++++++++ BUILD.SH ++++++++++\n"
    printf "+++ %s \n" $1
    printf "+++++++++++++++++++++++++++++++\n"
}

export APP_NAME="TortoiseHg"
export THG_VERSION="4.9.1"
export QT_VERSION="qt5"

. toolchain/build_settings.conf

PRECOMPILED_FILE="${DISTDIR}.zip"
if [ -f $PRECOMPILED_FILE ]; then
    unzip ${PRECOMPILED_FILE} -d ${ROOT_DIR}/toolchain
fi
ls -la ${DISTDIR}

rm -rf dist/TortoiseHg.app

mkdir -p ${DOWNLOADDIR}

# build/verify dependencies
log openssl.sh
sh toolchain/receipts/openssl.sh
log python.sh
sh toolchain/receipts/python.sh
log pip.sh
sh toolchain/receipts/pip.sh

if [ ${QT_VERSION} = "qt5" ]; then
  log qt5.sh
  sh toolchain/receipts/qt5.sh
else
  log qt4.sh
  sh toolchain/receipts/qt4.sh
fi
log qscintilla.sh
sh toolchain/receipts/qscintilla.sh
log sip.sh
sh toolchain/receipts/sip.sh
if [ ${QT_VERSION} = "qt5" ]; then
    log pyqt5.sh
    sh toolchain/receipts/pyqt5.sh
else
    log pyq4.sh
    sh toolchain/receipts/pyqt4.sh
fi

log qscintilla.sh
sh toolchain/receipts/qscintilla.sh
log packages.sh
sh toolchain/receipts/packages.sh

# build mercurial + tortoisehg
log mercurial.sh
sh toolchain/receipts/mercurial.sh
log tortoisehg.sh
sh toolchain/receipts/tortoisehg.sh

# create application package
log "application package"

python setup.py

if [ -d dist/${APP_NAME}.app ]; then
  log "rm -rf build..."
  rm -rf build
  rm -rf toolchain/build

  if [ "${QT_VERSION}" = "qt5" ]; then
    macdeployqt dist/${APP_NAME}.app -always-overwrite
    cp -R ${DISTDIR}/usr/lib/QtNetwork.framework dist/${APP_NAME}.app/Contents/Frameworks/
  fi
  log "createDmg.sh"
  sh toolchain/receipts/createDmg.sh
fi
