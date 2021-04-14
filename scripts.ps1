### Global variables
$RTOOLS_ARCH = ${env:RTOOLS_ARCH}
$RTOOLS_ZIP = "rtools40-${RTOOLS_ARCH}.7z"
$RTOOLS_EXE = "rtools40-${RTOOLS_ARCH}.exe"
#$ErrorActionPreference = "Stop";

### Use for bootstrapping installation
$RTOOLS_MIRROR = "https://dl.bintray.com/rtools/installer/"
# $RTOOLS_MIRROR = "https://cloud.r-project.org/bin/windows/Rtools/"
# $RTOOLS_MIRROR = "https://ftp.opencpu.org/archive/rtools/4.0/"

### InnoSetup Mirror
# $INNO_MIRROR = "http://jrsoftware.org/download.php/is-unicode.exe?site=2"
$INNO_MIRROR = "http://files.jrsoftware.org/is/6/innosetup-6.0.4.exe"

function CheckExitCode($msg) {
  if ($LastExitCode -ne 0) {
    Throw $msg
  }
}

# Unzip and Initiate Rtools dump
Function InstallRtoolsZip {
	Write-Host "Installing ${RTOOLS_ZIP}..." -ForegroundColor Cyan
	$tmp = "$($env:USERPROFILE)\${RTOOLS_ZIP}"
	(New-Object Net.WebClient).DownloadFile($RTOOLS_MIRROR + $RTOOLS_ZIP, $tmp)
	7z x $tmp -y -oC:\ | Out-Null
	CheckExitCode "Failed to extract ${RTOOLS_ZIP}"
	C:\rtools40\usr\bin\bash.exe --login -c exit 2>$null
	Write-Host "Installation of ${RTOOLS_ZIP} done!" -ForegroundColor Green
}

# Don't use installer when: (1) architecture doesn't match host (2) Dir C:/rtools40 already exists
Function InstallRtoolsExe {
	Write-Host "Installing ${RTOOLS_EXE}..." -ForegroundColor Cyan
	$tmp = "$($env:USERPROFILE)\${RTOOLS_EXE}"	
	(New-Object Net.WebClient).DownloadFile($RTOOLS_MIRROR + $RTOOLS_EXE, $tmp)
	Start-Process -FilePath $tmp -ArgumentList /VERYSILENT -NoNewWindow -Wait
	CheckExitCode "Failed to install ${RTOOLS_EXE}"
	Write-Host "Installation of ${RTOOLS_EXE} done!" -ForegroundColor Green
}

function bash($command) {
    Write-Host $command -NoNewline
    cmd /c start /wait C:\rtools40\usr\bin\sh.exe --login -c $command
    Write-Host " - OK" -ForegroundColor Green
}

function InstallRtools {
	InstallRtoolsZip
	bash 'pacman -Sy --noconfirm pacman pacman-mirrors'
	#bash 'pacman -Syyu --noconfirm --ask 20'
}

Function InstallInno {
  Write-Host "Downloading InnoSetup from: " + $INNO_MIRROR
  & "C:\Program Files\Git\mingw64\bin\curl.exe" -s -o ../innosetup.exe -L $INNO_MIRROR
  CheckExitCode "Failed to download $INNO_MIRROR"

  Write-Host "Installig InnoSetup..."
  Start-Process -FilePath ..\innosetup.exe -ArgumentList "/ALLUSERS /SILENT" -NoNewWindow -Wait
  CheckExitCode "Failed to install InnoSetup"

  Write-Host "InnoSetup installation: Done" -ForegroundColor Green
  Get-ItemProperty "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
}

Function Progress {
    [CmdletBinding()]
    param (
        [Parameter(Position=0, Mandatory=0)]
        [string]$Message = ""
    )

    $ProgressMessage = '== ' + (Get-Date) + ': ' + $Message

    Write-Host $ProgressMessage -ForegroundColor Magenta
}

function InnoBuild($iss){
	Write-Host "Creating installer..." -NoNewline
	& "C:\Program Files (x86)\Inno Setup 6\iscc.exe" "${env:INSTALLER}" | Out-File output.log
	Copy-Item Output\rtools40-x86_64.exe
	Write-Host "OK!" -ForegroundColor Green
}

function SignFiles($files) {
  & $env:SignTool sign /f $env:KeyFile /p "$env:CertPassword" /tr http://sha256timestamp.ws.symantec.com/sha256/timestamp /td sha256 /fd sha256 $files
  CheckExitCode "Failed to sign files."
}

########### OLD CODE ###########

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

function rtools_bootstrap {
	# AppVeyor only has msys64 preinstalled
	if($env:MSYS_VERSION -eq 'msys32') {
		InstallMSYS32
		bash 'pacman -Sy --noconfirm pacman pacman-mirrors'

		# May upgrade runtime, need to exit afterwards
		bash 'pacman -Syyuu --noconfirm --ask 20'
	}
	bash 'pacman --version'
	bash 'pacman --noconfirm -Rcsu mingw-w64-x86_64-toolchain mingw-w64-i686-toolchain'
	bash 'repman add rtools "https://dl.bintray.com/rtools/${MSYSTEM_CARCH}"'
	bash 'pacman --noconfirm --sync rtools/pacman-mirrors rtools/pacman rtools/tar'
	bash 'mv /etc/pacman.conf /etc/pacman.conf.old'
	bash 'mv /etc/pacman.conf.pacnew /etc/pacman.conf'
	bash 'pacman --noconfirm -Scc'
	bash 'pacman --noconfirm --ask 20 -Syyu'
}

Function UpdateMSYS2 {
	C:\msys64\usr\bin\pacman --noconfirm -Sy
	C:\msys64\usr\bin\pacman --noconfirm --needed -S msys2-runtime msys2-runtime-devel mintty
	C:\msys64\usr\bin\pacman --noconfirm --needed -S bash pacman
}
