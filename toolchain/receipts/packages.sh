#!/bin/sh

. toolchain/build_settings.conf

if [ ! -d "${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages/iniparse" ]; then
  echo "Install iniparse"
  pip install iniparse
fi

if [ ! -d "${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages/pygments" ]; then
  echo "Install Pygments"
  pip install Pygments
fi

if [ ! -d "${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages/py2app" ]; then
  echo "Install py2app"
  pip install py2app

  if [ ${QT_VERSION} = "qt5" ]; then
    cp toolchain/patches/main-x86_64 ${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages/py2app/apptemplate/prebuilt
  fi
fi

if [ ! -d "${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages/mercurial_keyring" ]; then
  echo "Install mercurial_keyring"
  pip install mercurial_keyring
fi
