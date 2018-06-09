# Rtools Installer Bundle [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-windows/installer)](https://ci.appveyor.com/project/jeroen/installer)

> Build the Rtools bundle archive and installer.

Simple [script](make-rtools-installer.sh) to setup a blank msys2 environment in a chroot dir. Based on [msys2-installer](https://github.com/msys2/msys2-installer) code, but using inno setup instead of qt-installer-framework.

## AppVeyor

The [appveyor script](scripts.ps1) bootstraps the build environment by swapping repositories to rtools on the existing appveyor msys2 installation.
