#/bin/sh -xv

# Configure shell to exit if any script finish with error
set -e
# Configure bashism to exit if piped output also finish with error
set -o pipefail

SHELL="time sh -xv"
function log() {
    printf "+++++++++++ BUILD.SH ++++++++++\n"
    printf "+++ %s \n" $1
    printf "+++++++++++++++++++++++++++++++\n"
}

function print_env() {
    printf "+-------------------------------\n"
    which -a python
    which -a pip
    printf "+EXPORT \n"
    export
    printf "PWD:${PWD}\n"
    printf "DOWNLOADDIR:${DOWNLOADDIR}\n"
    printf "BUILDDIR:${BUILDDIR}\n"
    printf "DISTDIR:${DISTDIR}\n"
    printf "MACOSX_DEPLOYMENT_TARGET:${MACOSX_DEPLOYMENT_TARGET}\n"
    printf "DISTDIR:${DISTDIR}\n"
    printf "SDKROOT:${SDKROOT}\n"
    printf "PATH:${PATH}\n"
    printf "+-------------------------------\n"
}

export APP_NAME="TortoiseHg"
export THG_VERSION="4.9.1"
export QT_VERSION="qt5"

. toolchain/build_settings.conf

print_env

PRECOMPILED_FILE="${DISTDIR}.zip"
if [ -f $PRECOMPILED_FILE ]; then
    log "using precompiled libraries"
    unzip -q ${PRECOMPILED_FILE} -d ${ROOT_DIR}/toolchain
fi
ls -la ${DISTDIR}

rm -rf dist/TortoiseHg.app

# build/verify dependencies
log openssl.sh
${SHELL} toolchain/receipts/openssl.sh
log python.sh
${SHELL} toolchain/receipts/python.sh
log pip.sh
${SHELL} toolchain/receipts/pip.sh

print_env

if [ ${QT_VERSION} = "qt5" ]; then
  log qt5.sh
  ${SHELL} toolchain/receipts/qt5.sh
else
  log qt4.sh
  ${SHELL} toolchain/receipts/qt4.sh
fi
log qscintilla.sh
${SHELL} toolchain/receipts/qscintilla.sh
log sip.sh
${SHELL} toolchain/receipts/sip.sh
if [ ${QT_VERSION} = "qt5" ]; then
    log pyqt5.sh
    ${SHELL} toolchain/receipts/pyqt5.sh
else
    log pyq4.sh
    ${SHELL} toolchain/receipts/pyqt4.sh
fi

log qscintilla.sh
${SHELL} toolchain/receipts/qscintilla.sh

print_env

log packages.sh
${SHELL} toolchain/receipts/packages.sh

# build mercurial + tortoisehg
log mercurial.sh
${SHELL} toolchain/receipts/mercurial.sh
log tortoisehg.sh
${SHELL} toolchain/receipts/tortoisehg.sh

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
  ${SHELL} toolchain/receipts/createDmg.sh
fi
