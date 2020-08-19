#!/usr/bin/env bash

# Set our custom repositories
scriptdir=$(dirname "$0")
cp -f "${scriptdir}/dummy.conf" /etc/pacman.conf
pacman -Syy

# rtools support pkgs (toolchains below)
# Potential risk of PATH conflicts: curl, perl (via texinfo texinfo-tex), gpg
_rtools_msys_pkgs="rsync winpty file bsdtar findutils libxml2 libexpat mintty msys2-launcher pacman curl make tar texinfo texinfo-tex patch diffutils gawk grep rebase zip unzip gzip"

_thisdir="$(dirname $0)"
test "${_thisdir}" = "." && _thisdir=${PWD}
_arch=$(uname -m)
_date=$(date +'%Y%m%d')
_version=${_date}
_filename2=rtools-${_arch}-${_date}.tar.xz

if [ "${_arch}" = "x86_64" ]; then
  _bitness=64
  _rtools_mingw_pkgs="mingw-w64-{i686,x86_64}-{gcc-fortran,pkg-config,tools}"
else
  _bitness=32
  _rtools_mingw_pkgs="mingw-w64-i686-{gcc-fortran,pkg-config,tools}"
fi

#_newmsysbase=/tmp/newmsys
_newmsysbase="${_thisdir}/build"
_newbasename="rtools40"
_newmsys="${_newmsysbase}/${_newbasename}"
_log="${_thisdir}/installer-${_arch}-${_date}.log"

create_archives() {
  local _dirs=
  for curr_dir in /etc /var /tmp /usr /mingw32 /mingw64 /msys2_shell.cmd /msys2.exe /mingw32.exe /mingw64.exe /msys2.ini /mingw32.ini /mingw64.ini /msys2.ico /autorebase.bat autorebasebase1st.bat; do
    if [[ -d ${_newmsys}${curr_dir} || -f ${_newmsys}${curr_dir} ]]; then
      _dirs="${_dirs} ${_newmsys}$curr_dir"
    fi
  done

  if [ -n "${_dirs}" ]; then
    pushd ${_newmsysbase} > /dev/null
      local _compress_cmd2="/usr/bin/tar --transform='s/:/_/g' --dereference --hard-dereference -cJf ${_thisdir}/${_filename2} ${_newbasename}"
      echo "Run: ${_compress_cmd2} ..." | tee -a ${_log}
      eval "${_compress_cmd2}" 2>&1 | tee -a ${_log}
      _result=$?
      if [ "${_result}" -eq "0" ]; then
            echo " tar succeeded. Created " | tee -a ${_log}
      else
            die "MSYS2 compressing fail. See ${_log}"
      fi
    popd > /dev/null
  fi
}

create_chroot_system() {
  [ -d ${_newmsysbase} ] && rm -rf ${_newmsysbase}
  mkdir -p "${_newmsys}"
  pushd "${_newmsys}" > /dev/null

    mkdir -p var/lib/pacman
    mkdir -p var/log
    mkdir -p tmp

    eval "pacman -Syu --root \"${_newmsys}\"" | tee -a ${_log}
    eval "pacman -S ${_rtools_msys_pkgs} ${_rtools_mingw_pkgs} --noconfirm --root \"${_newmsys}\"" | tee -a ${_log}
    _result=$?
    if [ "${_result}" -ne "0" ]; then
      echo "failed to create msys2 chroot in ${_newmsys}"
      exit 1
    fi

    # Change user home directory to match Windows
    echo "Patching nsswitch.conf"
    sed -i 's/db_home: cygwin/db_home: windows #cygwin/' ./etc/nsswitch.conf
    echo "OK:"
    cat ./etc/nsswitch.conf

    # Adding scripts to user profile
    echo "Copy aliases.sh gitbin.sh"
    cp "${_thisdir}/aliases.sh" ./etc/profile.d/
    cp "${_thisdir}/gitbin.sh" ./etc/profile.d/

    # Comments out upstream msys2 (is now hardcoded in pacman)
    # patch -p0 -i ${_thisdir}/disable-msys.patch

  popd > /dev/null
}

rm -f "${_log}"
echo "Creating MSYS2 chroot system ${_newmsys}" | tee -a ${_log}
create_chroot_system

# Test that it worked
if [ -f "${_newmsys}/mingw32/bin/gcc.exe" ]; then
  echo "Success!"
  exit 0
else
  echo "Failed to install rtools in chroot :("
  exit 1
fi
