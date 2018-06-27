[Setup]
AppName=Rtools
AppVersion=4.0
VersionInfoVersion=4.0.0.1
AppPublisher=The R Foundation
AppPublisherURL=https://cran.r-project.org/bin/windows/Rtools
AppSupportURL=https://cran.r-project.org/bin/windows/Rtools
AppUpdatesURL=https://cran.r-project.org/bin/windows/Rtools
DefaultDirName=C:\rtools40
DefaultGroupName=Rtools 4.0 (beta)
UninstallDisplayName=Rtools 4.0 (beta)
;InfoBeforeFile=docs\Rtools.txt
SetupIconFile=favicon.ico
UninstallDisplayIcon=favicon.ico
WizardSmallImageFile=icon-small.bmp
OutputBaseFilename=rtools40-i686
Compression=lzma/ultra
SolidCompression=yes
PrivilegesRequired=none
ChangesEnvironment=yes
UsePreviousAppDir=no
DirExistsWarning=no
DisableProgramGroupPage=yes
ArchitecturesAllowed=x86
  
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "greek"; MessagesFile: "compiler:Languages\Greek.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl" 
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "serbian_cyrillic"; MessagesFile: "compiler:Languages\SerbianCyrillic.isl"
Name: "serbian_latin"; MessagesFile: "compiler:Languages\SerbianLatin.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

[Messages]
OnlyOnTheseArchitectures=The 32-bit installer cannot be used on 64-bit Windows. Please downloaded the 64-bit Rtools installer from CRAN.

[CustomMessages]
AlreadyExists=Target directory already exists: %1 %n%nPlease remove previous installation or select another location.

[Tasks]
;Name: setPath; Description: "Add rtools to system PATH"; Flags: unchecked; Check: IsAdmin
Name: recordversion; Description: "Save version information to registry"
Name: createStartMenu; Description: "Create start-menu icons to msys2 shells"

[Registry]
Root: HKLM; Subkey: "Software\R-core"; Flags: uninsdeletekeyifempty; Tasks: recordversion; Check: IsAdmin
Root: HKLM; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletekeyifempty; Tasks: recordversion; Check: IsAdmin
Root: HKLM; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletevalue; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Tasks: recordversion; Check: IsAdmin
Root: HKLM; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletevalue; ValueType: string; ValueName: "Current Version"; ValueData: "{code:SetupVer}"; Tasks: recordversion; Check: IsAdmin
Root: HKLM; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; Flags: uninsdeletekey; Tasks: recordversion; Check: IsAdmin
Root: HKLM; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Tasks: recordversion; Check: IsAdmin
Root: HKLM; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; Flags: uninsdeletevalue; ValueType: string; ValueName: "FullVersion"; ValueData: "{code:FullVersion}"; Tasks: recordversion; Check: IsAdmin

; Non-admin users in write to HKCU
Root: HKCU; Subkey: "Software\R-core"; Flags: uninsdeletekeyifempty; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletekeyifempty; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletevalue; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletevalue; ValueType: string; ValueName: "Current Version"; ValueData: "{code:SetupVer}"; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; Flags: uninsdeletekey; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; Flags: uninsdeletevalue; ValueType: string; ValueName: "FullVersion"; ValueData: "{code:FullVersion}"; Tasks: recordversion; Check: NonAdmin

[Files]
Source: "build\rtools40\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs 

[Run]
Filename: "{app}\autorebase.bat"; Description: "Rebase 32bit dll files (recommended)"; Flags: shellexec
Filename: "{app}\usr\bin\bash.exe"; Parameters: "--login -c exit"; Description: "Init rtools repositories"; Flags: postinstall

[Icons]
Name: "{group}\Rtools MinGW 32-bit"; Filename: "{app}\mingw32.exe"; Tasks: createStartMenu; Flags: excludefromshowinnewinstall
Name: "{group}\Rtools Bash"; Filename: "{app}\msys2.exe"; Tasks: createStartMenu; Flags: excludefromshowinnewinstall

[UninstallDelete]
Type: filesandordirs; Name: "{app}"

[Code]
function NextButtonClick(PageId: Integer): Boolean;
begin
    Result := True;
    if (PageId = wpSelectDir) and DirExists(WizardDirValue()) then begin
        MsgBox(FmtMessage(ExpandConstant('{cm:AlreadyExists}'), [WizardDirValue()]), mbError, MB_OK);
        Result := False;
        exit;
    end;
end;

function SetupVer(Param: String): String;
begin
  result := '{#SetupSetting("AppVersion")}';
end;

function FullVersion(Param: String): String;
begin
  result := '{#SetupSetting("VersionInfoVersion")}';
end;

function IsAdmin: boolean;
begin
  Result := IsAdminLoggedOn or IsPowerUserLoggedOn;
end;

function NonAdmin: boolean;
begin
  Result := not IsAdmin;
end;
