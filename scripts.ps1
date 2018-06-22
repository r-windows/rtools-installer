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
		#bash 'pacman -Syu --noconfirm'
		#bash 'pacman -Syu --noconfirm'
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
  $inno_url = "https://github.com/jrsoftware/issrc/releases/download/is-5_6_1/innosetup-5.6.1-unicode.exe"

  Write-Host "Downloading InnoSetup from: " + $inno_url
  & "C:\Program Files\Git\mingw64\bin\curl.exe" -s -o ../innosetup.exe -L $inno_url

  Write-Host "Installig InnoSetup..."
  Start-Process -FilePath ..\innosetup.exe -ArgumentList /SILENT -NoNewWindow -Wait

  Write-Host "InnoSetup installation: Done" -ForegroundColor Green
  Get-ItemProperty "C:\Program Files (x86)\Inno Setup 5\ISCC.exe"
}

function InnoBuild($iss){
	Write-Host "Creating installer..." -NoNewline
	& "C:\Program Files (x86)\Inno Setup 5\iscc.exe" "${env:RTOOLS_NAME}.iss" | Out-File output.log
	Write-Host "OK!" -ForegroundColor Green
}

function CheckExitCode($msg) {
  if ($LastExitCode -ne 0) {
    Throw $msg
  }
}

function SignFiles($files) {
  & $env:SignTool sign /f $env:KeyFile /p "$env:CertPassword" /tr http://sha256timestamp.ws.symantec.com/sha256/timestamp /td sha256 /fd sha256 $files
  CheckExitCode "Failed to sign files."
}

function bootstrap {
	rtools_bootstrap
	InstallInno
	#InstallRtools
}

Function InstallRtools {
  $rtoolsurl = "https://dl.bintray.com/rtools/installer/rtools40-${env:MSYSTEM_CARCH}.exe"

  Write-Host "Downloading InnoSetup from: " + $rtoolsurl
  & "C:\Program Files\Git\mingw64\bin\curl.exe" -s -o ../installer.exe -L $rtoolsurl

  Write-Host "Installig Rtools 4.0..."
  Start-Process -FilePath ..\installer.exe -ArgumentList /SILENT -NoNewWindow -Wait

  Write-Host "InnoSetup installation: Done" -ForegroundColor Green

  #Write-Host "Setting PATH"
  #$env:PATH = 'C:\rtools40\usr\bin;' + $env:PATH
  #$env:BINPREF = 'C:/rtools40/mingw$(WIN)/bin/'
}
