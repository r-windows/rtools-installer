# Rtools Installer Bundle [![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/r-windows/installer)](https://ci.appveyor.com/project/jeroen/installer)

> Build the Rtools bundle archive and installer.

Simple [script](make-rtools-installer.sh) to setup a blank msys2 environment in a chroot dir. Based on [msys2-installer](https://github.com/msys2/msys2-installer) code, but using inno setup instead of qt-installer-framework.

## About Rtools40

This is the windows toolchain and build environment for the R project. The current branch is based on:

 - gcc 8.1.0 (dwarf, seh)
 - mingw-w64 5.0.4
 - winpthreads

Rtools40 uses the [msys2](https://www.msys2.org/) build environment. One major benefit is that msys2 includes a fantastic package manager `pacman` that we can use to properly build, distribute, and install external c/c++ libraries for CRAN packages. Go try it :-)

```sh
# Sync with repositories
pacman -Sy

# Install a library
pacman -S mingw-w64-{i686,x86_64}-curl
```

The major difference between rtools and the upstream msys2 distribution is that our toolchains and external libraries have been reconfigured for static linking. This ensures that R packages built with rtools do not depend on any external dll files, and can be safely distributed as standalone binary packages.

## How to use

The toolchains are installed in `C:\rtools\mingw32` and `C:\rtools\mingw64`. Within these directories there is the usual `bin` for executables, and `include`, `lib` for libraries. These directories are completely managed by the package manager `pacman`. You should not manually add/remove files here, `pacman` will automatically install the proper files when installing or uninstalling packages.

You also don't have to pass special paths to the compiler when building R-base or R packages. The compiler has been configured to automatically find the proper headers and libraries that have been installed with pacman.

The rtools build utilities (`make`, `sh`, `sed`, etc) are installed `C:\rtools\usr\bin`. This location should be on the PATH when building. Anything in rtools under `C:\rtools\usr` is only used for running rtools itself; it will not be picked up by the toolchains.


## Installing packages


## Building R


## AppVeyor

The [appveyor script](scripts.ps1) bootstraps the build environment by swapping repositories to rtools on the existing appveyor msys2 installation.
