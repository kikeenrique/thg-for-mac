#!/bin/zsh -xv

# Configure shell to exit if any script finish with error
set -eu
# Configure bashism to exit if piped output also finish with error
set -o pipefail

function log() {
    printf "+++++++++++ BUILD.SH ++++++++++\n"
    printf "+++ %s \n" $1
    printf "+++++++++++++++++++++++++++++++\n"
}

function load_env() {
    export SHELL=(time zsh -xv)

    . toolchain/app_output_config.conf
    . toolchain/build_settings.conf

    export PRECOMPILED_FILE="${DISTDIR}.zip"
}

function print_env() {
    printf "+-------------------------------\n"
    which -a python3
    printf "+-------------------\n"
    which -a pip3 || true
    printf "+EXPORTED: \n"
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

function clean_build() {
    log clean_build

    rm -rf build
    rm -rf toolchain/build
}

function thg_environment() {
    # CFVersion is always x.y.z format.  The plain version will have changeset info
    # in non-tagged builds.
    export THG_CFVERSION=`python3 -c 'from tortoisehg.util import version; print(version.package_version())'`
    export THG_VERSION=`python3 -c 'from tortoisehg.util import version; print(version.version())'`
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

        macdeployqt dist/${APP_NAME}.app -always-overwrite
        cp -R ${DISTDIR}/usr/lib/QtNetwork.framework dist/${APP_NAME}.app/Contents/Frameworks/

        if [ -n "${CODE_SIGN_IDENTITY+1}" ]; then
            echo "Signing app bundle"
            src/thg/contrib/sign-py2app.sh dist/${APP_NAME}.app
        fi

        execute_receipt "createDmg.sh"
    fi
}

##### MAIN #####

load_env

print_env

rm -rf dist/TortoiseHg.app

# build/verify dependencies
execute_receipt openssl.sh
execute_receipt python.sh
execute_receipt pip.sh
print_env
execute_receipt packages.sh
execute_receipt "${QT_VERSION}.sh"
execute_receipt qscintilla.sh
execute_receipt sip.sh
execute_receipt "py${QT_VERSION}.sh"
execute_receipt qscintilla.sh
print_env
execute_receipt mercurial.sh
execute_receipt tortoisehg.sh
thg_environment

# create application package
log "application package"
python3 setup.py

create_DMG
