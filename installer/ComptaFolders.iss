; Inno Setup script for ComptaFolders
; Requires Inno Setup 6.x

#define AppName "ComptaFolders"
#define AppVersion "1.0.0"
#define AppPublisher "DevopsAbdel"
#define AppURL "https://github.com/DevopsAbdel/ComptaFolders"
#define AppExeName "ComptaFolders.exe"

[Setup]
AppId={{B7E3F2A1-4C5D-4E6F-8A9B-0C1D2E3F4A5B}}
AppName={#AppName}
AppVersion={#AppVersion}
AppPublisher={#AppPublisher}
AppPublisherURL={#AppURL}
AppSupportURL={#AppURL}
AppUpdatesURL={#AppURL}/releases
DefaultDirName={autopf}\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
OutputDir=..\dist
OutputBaseFilename=ComptaFolders-Setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "startmenu"; Description: "Creer un raccourci dans le Menu Demarrer"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
Source: "..\ComptaFolders.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\ComptaFolders.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\AppVersion.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\lib\*"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Resources\*"; DestDir: "{app}\Resources"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Documentation\*"; DestDir: "{app}\Documentation"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#AppName}"; Filename: "{app}\{#AppExeName}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: desktopicon
Name: "{userstartmenu}\Programs\{#AppName}\{#AppName}"; Filename: "{app}\{#AppExeName}"; Tasks: startmenu

[Run]
Filename: "{app}\{#AppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(AppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"