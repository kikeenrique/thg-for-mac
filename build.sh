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

function execute_receipt() {
    log $1
    ${SHELL} toolchain/receipts/$1
}

function zip_precompiled() {
    # create zip cached, not on bitrise
    if [ -z "${BITRISE_APP_TITLE}" ]; then
        cd "${DISTDIR}/.."
        if [ "${QT_VERSION}" = "qt5" ]; then
          export TARGET="toolchain-qt5"
        else
          export TARGET="toolchain-qt4"
        fi
        echo "${PRECOMPILED_FILE} ${TARGET}"
        rm -f ${PRECOMPILED_FILE}
        zip -rq ${PRECOMPILED_FILE} ${TARGET}
        cd ${ROOT}
    fi
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
execute_receipt openssl.sh
execute_receipt python.sh
execute_receipt pip.sh

print_env

execute_receipt "${QT_VERSION}.sh"

execute_receipt qscintilla.sh
execute_receipt sip.sh

execute_receipt "py${QT_VERSION}.sh"

execute_receipt qscintilla.sh

print_env

execute_receipt packages.sh

# build mercurial + tortoisehg
execute_receipt mercurial.sh
execute_receipt tortoisehg.sh

# create application package
log "application package"

python setup.py

zip_precompiled

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
