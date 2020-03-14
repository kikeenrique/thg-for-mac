#!/bin/zsh

set -euo pipefail

. toolchain/build_settings.conf

export PYTHONVERBOSE=1

python3 -m pip install pip-tools
pip-compile --generate-hashes --output-file=toolchain/receipts/requirements.txt toolchain/receipts/requirements.txt.in
pip3 install -r toolchain/receipts/requirements.txt

cp toolchain/patches/main-x86_64 ${DISTDIR}/System/Library/Frameworks/Python.framework/Versions/Current/lib/python3.7/site-packages/py2app/apptemplate/prebuilt
