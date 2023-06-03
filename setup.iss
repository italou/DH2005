#define GameName "Deer Hunter 2005"
#define MyAppVersion "1.2"
#define MySetupFile "DH2005mp"
#define InstIcon "install.ico"
#define UninstIcon "uninstall.ico"
#define GameExe "DH2005.exe"
#define MyAppPublisher "HU Corner"
#define MyAppURL "http://hucorner.imbl.net/"

[Setup]
AppName={#GameName} HU Corner ModPack
AppVersion={#MyAppVersion}
AppVerName={#SetupSetting("AppName")} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
VersionInfoVersion={#SetupSetting("AppVersion")}
DefaultGroupName={code:GetDHGroup}
SetupIconFile=inno_files\{#InstIcon}
DefaultDirName={code:GetDHPath}\hucmp
CreateAppDir=yes
DisableDirPage=yes
UninstallDisplayIcon={app}\{#InstIcon}
UninstallFilesDir={app}
InfoBeforeFile=info.txt
WizardSmallImageFile=inno_files\logoimg.bmp
WizardImageFile=inno_files\sideimg.bmp
OutputDir=.
OutputBaseFilename={#MySetupFile}
Compression=lzma
SolidCompression=yes
;Uninstallable=false
DisableProgramGroupPage=yes
;SetupLogging=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: nocd; Description: "Install NoCD game executable";

[Files]
Source: "Game\Data.001"; DestDir: "{code:GetDHPath}\Game"; BeforeInstall: BackupFile('Data.001'); Flags: ignoreversion
Source: "Game\DH2005.exe"; DestDir: "{code:GetDHPath}"; BeforeInstall: BackupFile('DH2005.exe'); Flags: ignoreversion; Tasks: nocd
Source: "inno_files\{#UninstIcon}"; DestDir: "{app}"; Flags: ignoreversion
Source: "inno_files\hucorner.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "inno_files\link_HUCorner.url"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Uninstall {#SetupSetting("AppName")}"; Filename: "{uninstallexe}"; IconFilename: "{app}\{#UninstIcon}"
Name: "{group}\Visit HU Corner site"; Filename: "{app}\link_HUCorner.url"; IconFilename: "{app}\hucorner.ico"

[Messages]
SetupAppTitle={#SetupSetting("AppVerName")} Installer
SetupWindowTitle={#SetupSetting("AppVerName")} Installer
UninstallAppTitle={#SetupSetting("AppVerName")} Uninstaller
UninstallAppFullTitle={#SetupSetting("AppVerName")} Uninstaller

[Registry]
Root: HKCU; Subkey: "Software\HU Corner\{#SetupSetting("AppName")}"; ValueType: string; ValueName: "Version"; ValueData: "{#MyAppVersion}"; Flags: uninsdeletekey
Root: HKCU; Subkey: "Software\HU Corner\{#SetupSetting("AppName")}"; ValueType: string; ValueName: "GamePath"; ValueData: "{code:GetDHPath}"; Flags: uninsdeletekey

[Run]
Filename: "{code:GetDHPath}\{#GameExe}"; Description: "Launch {#SetupSetting("AppName")}"; Flags: postinstall nowait skipifsilent unchecked

[Code]
const
   QuitMessageError = '{#GameName} installation was not detected on this system.'#13#13'Installation will now stop.';
   NotUpdatedError = '{#GameName} v1.2 was not detected on this system.'#13#13'Installation will now stop.';

var
   DHPath, DHGroup: String;

procedure BackupFile(FileToBackup : String);
begin
  if (FiletoBackup = 'Data.001') then begin
    if not FileExists(DHPath + '\hucmp\data001.bak') then begin
      CreateDir(DHPath + '\hucmp');
      FileCopy(DHPath + '\Game\Data.001', DHPath + '\hucmp\data001.bak', false);
    end;
  end else if (FiletoBackup = 'DH2005.exe') then begin
    if not FileExists(DHPath + '\hucmp\DH2005.bak') then begin
      CreateDir(DHPath + '\hucmp');
      FileCopy(DHPath + '\DH2005.exe', DHPath + '\hucmp\DH2005.bak', false);
    end;      
  end;
end;

function InitializeSetup(): Boolean;
var
  KeyValue: String;

begin

 if RegQueryStringValue(HKLM, 'Software\Wow6432Node\Southlogic\DH2005', 'InstallPath', KeyValue) then begin
    DHPath := KeyValue;
    Result := true;
  end else if RegQueryStringValue(HKLM, 'Software\Southlogic\DH2005', 'InstallPath', KeyValue) then begin
    DHPath := KeyValue;
    Result := true;
  end else begin
    MsgBox(QuitMessageError, mbError, mb_Ok);
    Result := false;
    exit;
  end;

  if not FileExists(DHPath + '\ReadMe_v1.2.txt') then begin
    MsgBox(NotUpdatedError, mbError, mb_Ok);
    Result := false;
    exit;
  end;

  if RegQueryStringValue(HKLM, 'Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Deer Hunter 2005_is1', 'Inno Setup: Icon Group', KeyValue) then begin
    DHGroup := KeyValue;
  end else if RegQueryStringValue(HKLM, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\Deer Hunter 2005_is1', 'Inno Setup: Icon Group', KeyValue) then begin
    DHGroup := KeyValue;
  end else begin
    DHGroup := 'Atari\{#SetupSetting("GameName")}';
  end;
end;

function GetDHPath(Param: String): String;
begin
   Result := DHPath;
end;

function GetDHGroup(Param: String): String;
begin
   Result := DHGroup;
end;

function InitializeUninstall(): Boolean;
begin
  if not RegQueryStringValue(HKCU, 'Software\HU Corner\{#SetupSetting("AppName")}', 'GamePath', DHPath) then begin
    MsgBox('Missing uninstall information data.'#13'Please reinstall {#SetupSetting("AppVerName")}', mbError, mb_Ok);
    Result := false;
  end else if not FileExists(DHPath + '\hucmp\data001.bak') then begin
    MsgBox('Missing backup file: ' + DHPath + '\hucmp\data001.bak'#13'Please reinstall {#SetupSetting("AppVerName")}', mbError, mb_Ok);
    Result := false;
  end else begin
  Result := true;
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  if (CurUninstallStep = usPostUninstall) then begin
    FileCopy(DHPath + '\hucmp\data001.bak', DHPath + '\Game\Data.001', false);
    DeleteFile(DHPath + '\hucmp\data001.bak');
    if FileExists(DHPath + '\hucmp\DH2005.bak') then begin
      FileCopy(DHPath + '\hucmp\DH2005.bak', DHPath + '\DH2005.exe', false);
      DeleteFile(DHPath + '\hucmp\DH2005.bak');
    end;
  end;

  if (CurUninstallStep = usDone) then begin
    RemoveDir(DHPath + '\hucmp');
  end;
end;