#!/bin/sh -xv

. toolchain/build_settings.conf

echo "Install iniparse"
pip install -U iniparse

echo "Install Pygments"
pip install -U Pygments

echo "Install py2app"
pip install -U py2app

if [ ${QT_VERSION} = "qt5" ]; then
  cp toolchain/patches/main-x86_64 ${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages/py2app/apptemplate/prebuilt
fi

echo "Install mercurial_keyring"
pip install -U mercurial_keyring

echo "Install hg-git"
pip install -U hg-git
