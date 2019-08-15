#/bin/sh -xv

# Configure shell to exit if any script finish with error
set -e
# Configure bashism to exit if piped output also finish with error
set -o pipefail

function log() {
    printf "+++++++++++ BUILD.SH ++++++++++\n"
    printf "+++ %s \n" $1
    printf "+++++++++++++++++++++++++++++++\n"
}

function load_env() {
    export SHELL="time sh -xv"

    export APP_NAME="TortoiseHg"
    export THG_VERSION="4.9.1"
    export QT_VERSION="qt5"

    . toolchain/build_settings.conf

    export PRECOMPILED_FILE="${DISTDIR}.zip"
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
    log "execute_receipt ${1}"
    ${SHELL} toolchain/receipts/$1
}

function zip_precompiled_build_dependencies() {
    log zip_precompiled_build_dependencies

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
        cd ${ROOT_DIR}
    fi
}

function unzip_precompiled_build_dependencies() {
    log unzip_precompiled_build_dependencies

    if [ ! -z "${BITRISE_APP_TITLE}" ]; then
        # unzip precompile, just on bitrise
        log "look for precompiled libraries... ${PRECOMPILED_FILE}"
        if [ -f ${PRECOMPILED_FILE} ]; then
            log "using precompiled libraries"
            unzip -q ${PRECOMPILED_FILE} -d ${ROOT_DIR}/toolchain
        fi
        ls -la ${DISTDIR}
    fi
}

function clean_build() {
    log clean_build

    rm -rf build
    rm -rf toolchain/build
}
function clean_all() {
    log clean_all

    clean_build
    rm -rf .eggs
    rm -rf src/thg/
    rm -rf dist/
    rm -rf ${DISTDIR}
}

function create_DMG() {
    log create_DMG
    if [ -d dist/${APP_NAME}.app ]; then
        clean_build

        if [ "${QT_VERSION}" = "qt5" ]; then
            macdeployqt dist/${APP_NAME}.app -always-overwrite
            cp -R ${DISTDIR}/usr/lib/QtNetwork.framework dist/${APP_NAME}.app/Contents/Frameworks/
        fi
        execute_receipt "createDmg.sh"
    fi
}

##### MAIN #####

load_env

unzip_precompiled_build_dependencies

print_env

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
execute_receipt mercurial.sh
execute_receipt tortoisehg.sh

# create application package
log "application package"
python setup.py

zip_precompiled_build_dependencies

create_DMG
