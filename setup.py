"""
This is a setup.py script generated by py2applet

Usage:
    python setup.py py2app
"""

import shutil
import os
import sys
from setuptools import setup

print("CWD:" + os.getcwd() + "\n")

BUILDDIRTHG = os.environ['BUILDDIR'] + "/tortoisehg-" + os.environ['THG_VERSION']
BUILDDIRHG = os.environ['BUILDDIR'] + "/mercurial-" + os.environ['THG_VERSION']


shutil.copyfile( BUILDDIRTHG + '/thg', 'src/thg.py')
APP = [ 'src/thg.py']

DATA_FILES = [
    BUILDDIRTHG + '/icons',
    BUILDDIRTHG + '/locale',
    BUILDDIRTHG + '/COPYING.txt',
]

if os.environ['QT_VERSION'] == 'qt5':
    PYQT_VERSION = 'PyQt5'
    QT_PLUGINS = []
else:
    PYQT_VERSION = 'PyQt4'
    QT_PLUGINS = [ 'imageformats' ]

EXCLUDES = [
    PYQT_VERSION + '.QtScriptTools',
    PYQT_VERSION + '.QtMultimedia',
    PYQT_VERSION + '.QtDesigner',
    PYQT_VERSION + '.QtOpenGL',
    PYQT_VERSION + '.QtXmlPatterns',
    PYQT_VERSION + '.QtDBus',
    PYQT_VERSION + '.QtHelp',
    PYQT_VERSION + '.QtDeclarative',
    PYQT_VERSION + '.QtScript',
    PYQT_VERSION + '.QtSql',
    PYQT_VERSION + '.QtTest',
    PYQT_VERSION + '.QtWebKit',
    PYQT_VERSION + '.phonon',
]

sys.path.append('src/extra')
OPTIONS = {
    'includes' : ['email.mime.text', 'mercurial_keyring', 'sip', 'sitecustomize'],
    'packages' : ['certifi', 'mercurial', 'hgext', 'tortoisehg', 'pygments', 'iniparse', 'keyring'],
    'excludes' : EXCLUDES,
    'iconfile' : 'src/TortoiseHg.icns',
    'qt_plugins' : QT_PLUGINS,
    'plist' : dict(
        LSEnvironment = dict(
        HGENCODING = 'utf-8',
        THG_OSX_APP = '1',
        QT_API = PYQT_VERSION
    ),
    CFBundleDisplayName = 'TortoiseHg',
    CFBundleIdentifier = 'org.pythonmac.tortoisehg.thg',
    CFBundleName = 'TortoiseHg',
    NSHumanReadableCopyright = 'Copyright 2008-2018 Steve Borho and others',
    CFBundleShortVersionString = os.environ['THG_VERSION'],
    CFBundleVersion = os.environ['THG_VERSION']
    )
}

try:
    os.makedirs(os.getcwd() + '/src/thg/tortoisehg/util')
except OSError:
    pass
shutil.copyfile('src/config.py', 'src/thg/tortoisehg/util/config.py')

# set the command line to run py2app
sys.argv = ['setup.py', 'py2app']

setup(
    app=APP,
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)

shutil.copyfile( 'src/config.py', 'dist/TortoiseHg.app/Contents/Resources/lib/python2.7/tortoisehg/util/config.py')
shutil.copyfile( BUILDDIRHG + '/hg', 'dist/TortoiseHg.app/Contents/Resources/lib/python2.7/hg')
os.chmod('dist/TortoiseHg.app/Contents/Resources/lib/python2.7/hg', 0755)
