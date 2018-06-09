# Only install when building for 32bit
Function InstallMSYS32 {
	Write-Host "Installing MSYS2 32-bit..." -ForegroundColor Cyan

	# download installer
	$zipPath = "$($env:USERPROFILE)\msys2-i686-latest.tar.xz"
	$tarPath = "$($env:USERPROFILE)\msys2-i686-latest.tar"
	Write-Host "Downloading MSYS installation package..."
	(New-Object Net.WebClient).DownloadFile('http://repo.msys2.org/distrib/msys2-i686-latest.tar.xz', $zipPath)

	Write-Host "Untaring installation package..."
	7z x $zipPath -y -o"$env:USERPROFILE" | Out-Null

	Write-Host "Unzipping installation package..."
	7z x $tarPath -y -oC:\ | Out-Null
	del $zipPath
	del $tarPath
}

function bash($command) {
    Write-Host $command -NoNewline
    cmd /c start /wait "C:\$($env:MSYS_VERSION)\usr\bin\sh.exe" --login -c $command
    Write-Host " - OK" -ForegroundColor Green
}

function msys32boostrap {
	if($env:MSYS_VERSION -eq 'msys32') {
		InstallMSYS32
		bash 'pacman -Sy --noconfirm pacman pacman-mirrors'
		bash 'pacman -Syu --noconfirm'
		bash 'pacman -Syu --noconfirm'
	}
}

function rtools_bootstrap {
	msys32boostrap
	bash 'pacman --version'
	bash 'pacman --noconfirm -Rcsu mingw-w64-x86_64-toolchain mingw-w64-i686-toolchain'
	bash 'repman add rtools "https://dl.bintray.com/rtools/${MSYSTEM_CARCH}"'
	bash 'pacman --noconfirm --sync rtools/pacman-mirrors rtools/pacman rtools/tar'
	bash 'mv /etc/pacman.conf /etc/pacman.conf.old'
	bash 'mv /etc/pacman.conf.pacnew /etc/pacman.conf'	
	bash 'pacman --noconfirm -Scc'
	bash 'pacman --noconfirm --ask 20 -Syyu'
}

Function InstallInno {
  $inno_url = "http://files.jrsoftware.org/is/5/innosetup-5.5.9-unicode.exe"

  Progress ("Downloading InnoSetup from: " + $inno_url)
  & "C:\Program Files\Git\mingw64\bin\curl.exe" -s -o ../innosetup.exe -L $inno_url

  Progress "Installig InnoSetup"
  Start-Process -FilePath ..\innosetup.exe -ArgumentList /SILENT -NoNewWindow -Wait

  Progress "InnoSetup installation: Done"
  Get-ItemProperty "C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
}

