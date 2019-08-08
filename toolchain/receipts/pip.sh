#!/bin/sh

. toolchain/build_settings.conf

NAME="pip"
VERIFY_FILE="$DISTDIR/System/Library/Frameworks/Python.framework/Versions/Current/bin/pip"
DOWNLOAD_ADDR="http://bootstrap.pypa.io/get-pip.py"
DOWNLOAD_FILE="${DOWNLOADDIR}/get-pip.py"

if [ ! -f $VERIFY_FILE ]; then

  if [ ! -f $DOWNLOAD_FILE ]; then
    echo "Downloading ${DOWNLOAD_ADDR}"
    curl -L $DOWNLOAD_ADDR --output ${DOWNLOAD_FILE}
  fi

  python ${DOWNLOAD_FILE}  --user

  cd $ROOT_DIR
else
  echo "${NAME} already installed."
  export PATH="$DISTDIR/System/Library/Frameworks/Python.framework/Versions/Current/bin/":$PATH

  echo "modifying installed ${NAME}"
  cat ${VERIFY_FILE}
  # For pip, replace shebang with a generic execution, without customs paths
#  sed -i '/#!/c\/usr/bin/env python' ${VERIFY_FILE}
  sed -i '' -e '1d' ${VERIFY_FILE}
  sed -i '' '1i\
#!/usr/bin/env python
'  ${VERIFY_FILE}
  cat ${VERIFY_FILE}

fi

