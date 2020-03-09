#!/bin/zsh

set -euo pipefail

. toolchain/build_settings.conf

export PYTHONVERBOSE=1

python -m pip install pip-tools
pip-compile --generate-hashes --output-file=toolchain/receipts/requirements.txt toolchain/receipts/requirements.txt.in
pip install -r toolchain/receipts/requirements.txt

cp toolchain/patches/main-x86_64 ${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python2.7/site-packages/py2app/apptemplate/prebuilt
