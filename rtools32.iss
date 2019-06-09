[Setup]
AppName=Rtools
AppVersion=4.0
VersionInfoVersion=4.0.0.13
AppPublisher=The R Foundation
AppPublisherURL=https://cran.r-project.org/bin/windows/Rtools
AppSupportURL=https://cran.r-project.org/bin/windows/Rtools
AppUpdatesURL=https://cran.r-project.org/bin/windows/Rtools
DefaultDirName=C:\rtools40
DefaultGroupName=Rtools 4.0 (beta 13)
UninstallDisplayName=Rtools 4.0 (beta 13)
;InfoBeforeFile=docs\Rtools.txt
SetupIconFile=favicon.ico
UninstallDisplayIcon={app}\mingw32.exe
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
Root: HKLM; Subkey: SYSTEM\CurrentControlSet\Control\Session Manager\Environment; ValueType: expandsz; Flags: uninsdeletevalue; ValueName: RTOOLS40_HOME; ValueData: "{app}"; Check: IsAdmin

; Non-admin users in write to HKCU
Root: HKCU; Subkey: "Software\R-core"; Flags: uninsdeletekeyifempty; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletekeyifempty; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletevalue; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletevalue; ValueType: string; ValueName: "Current Version"; ValueData: "{code:SetupVer}"; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; Flags: uninsdeletekey; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; Flags: uninsdeletevalue; ValueType: string; ValueName: "FullVersion"; ValueData: "{code:FullVersion}"; Tasks: recordversion; Check: NonAdmin
Root: HKCU; Subkey: Environment; ValueType: expandsz; Flags: uninsdeletevalue; ValueName: RTOOLS40_HOME; ValueData: "{app}"; Check: NonAdmin

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
