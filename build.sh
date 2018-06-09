#/bin/bash

export APP_NAME="TortoiseHg"
export THG_VERSION="4.6.0"
export QT_VERSION="qt5"

rm -rf dist/TortoiseHg.app

# build/verify dependencies
sh toolchain/receipts/openssl.sh
sh toolchain/receipts/python.sh
if [ ${QT_VERSION} = "qt5" ]; then
  sh toolchain/receipts/qt5.sh
else
  sh toolchain/receipts/qt4.sh
fi
sh toolchain/receipts/qscintilla.sh
sh toolchain/receipts/sip.sh
if [ ${QT_VERSION} = "qt5" ]; then
  sh toolchain/receipts/pyqt5.sh
else
  sh toolchain/receipts/pyqt4.sh
fi
sh toolchain/receipts/qscintilla.sh
sh toolchain/receipts/pip.sh
sh toolchain/receipts/packages.sh

# build mercurial + tortoisehg
sh toolchain/receipts/mercurial.sh
sh toolchain/receipts/tortoisehg.sh

# create application package
. toolchain/build_settings.conf
python setup.py

if [ -d dist/${APP_NAME}.app ]; then
  rm -rf build
  rm -rf toolchain/build

  if [ ${QT_VERSION} = "qt5" ]; then
    macdeployqt dist/${APP_NAME}.app -always-overwrite
    cp -R ${DISTDIR}/usr/lib/QtNetwork.framework dist/${APP_NAME}.app/Contents/Frameworks/
  fi
  sh toolchain/receipts/createDmg.sh
fi
