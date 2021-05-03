[Setup]
AppName=Rtools
AppVersion=4.0
VersionInfoVersion=4.0.1.0
AppPublisher=The R Foundation
AppPublisherURL=https://cran.r-project.org/bin/windows/Rtools
AppSupportURL=https://cran.r-project.org/bin/windows/Rtools
AppUpdatesURL=https://cran.r-project.org/bin/windows/Rtools
DefaultDirName=C:\rtools40
DefaultGroupName=Rtools 4.0
UninstallDisplayName=Rtools 4.0 (4.0.1.0)
;InfoBeforeFile=docs\Rtools.txt
SetupIconFile=favicon.ico
UninstallDisplayIcon={app}\mingw64.exe
WizardSmallImageFile=icon-small.bmp
OutputBaseFilename=rtools40-x86_64
Compression=lzma/ultra
SolidCompression=yes
PrivilegesRequired=none
PrivilegesRequiredOverridesAllowed=commandline
ChangesEnvironment=yes
UsePreviousAppDir=no
DirExistsWarning=no
DisableProgramGroupPage=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Messages]
OnlyOnTheseArchitectures=The 64-bit installer cannot be used on 32-bit Windows. Please downloaded the 32-bit Rtools installer from CRAN.

[CustomMessages]
AlreadyExists=Target directory already exists: %1 %n%nPlease remove previous installation or select another location.

[Tasks]
Name: recordversion; Description: "Save version information to registry"
Name: createStartMenu; Description: "Create start-menu icons to msys2 shells"

[Registry]
Root: HKA; Subkey: "Software\R-core"; Flags: uninsdeletekeyifempty; Tasks: recordversion
Root: HKA; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletekeyifempty; Tasks: recordversion
Root: HKA; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletevalue; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Tasks: recordversion
Root: HKA; Subkey: "Software\R-core\Rtools"; Flags: uninsdeletevalue; ValueType: string; ValueName: "Current Version"; ValueData: "{code:SetupVer}"; Tasks: recordversion
Root: HKA; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; Flags: uninsdeletekey; Tasks: recordversion
Root: HKA; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; ValueType: string; ValueName: "InstallPath"; ValueData: "{app}"; Tasks: recordversion
Root: HKA; Subkey: "Software\R-core\Rtools\{code:SetupVer}"; Flags: uninsdeletevalue; ValueType: string; ValueName: "FullVersion"; ValueData: "{code:FullVersion}"; Tasks: recordversion;

; Non-admin users in write to HKCU
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; ValueType: expandsz; Flags: uninsdeletevalue; ValueName: RTOOLS40_HOME; ValueData: "{app}"; Check: IsAdmin
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; Flags: uninsdeletevalue; ValueName: RTOOLS40_HOME; ValueData: "{app}"; Check: NonAdmin

[Files]
Source: "build\rtools40\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Dirs]
Name: "{app}\mingw32"; Permissions: users-modify
Name: "{app}\mingw64"; Permissions: users-modify
Name: "{app}\ucrt64"; Permissions: users-modify
Name: "{app}\var\lib\pacman"; Permissions: users-modify
Name: "{app}\var\cache\pacman"; Permissions: users-modify

[Run]
;Filename: "{app}\usr\bin\bash.exe"; Parameters: "--login -c exit"; Description: "Init Rtools repositories"; Flags: postinstall
Filename: "{app}\usr\bin\bash.exe"; Parameters: "--login -c exit"; Description: "Init Rtools repositories"; Flags: nowait runhidden

[Icons]
Name: "{group}\Rtools MinGW 32-bit"; Filename: "{app}\mingw32.exe"; Tasks: createStartMenu; Flags: excludefromshowinnewinstall
Name: "{group}\Rtools MinGW 64-bit"; Filename: "{app}\mingw64.exe"; Tasks: createStartMenu; Flags: excludefromshowinnewinstall
Name: "{group}\Rtools MinGW 64-bit (UCRT)"; Filename: "{app}\ucrt64.exe"; Tasks: createStartMenu; Flags: excludefromshowinnewinstall
Name: "{group}\Rtools Bash"; Filename: "{app}\msys2.exe"; Tasks: createStartMenu; Flags: excludefromshowinnewinstall
Name: "{group}\Uninstall Rtools"; Filename: "{uninstallexe}"; Tasks: createStartMenu; Flags: excludefromshowinnewinstall; IconFilename: {sys}\Shell32.dll; IconIndex: 31

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
