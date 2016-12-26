#define MyAppName "Armadito-Agent"
#ifndef MyAppVersion
#define MyAppVersion "0.1.0_02"
#endif
#define MyAppPublisher "Teclib"
#define MyAppURL "https://www.armadito.com"
#define MyAppExeName "Armadito-Agent.exe"

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{ED2ED63B-3F06-44B8-A16E-A8DE0A6E2654}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
AllowRootDirectory=no
AllowUNCPath=no
AlwaysRestart=no
OutputBaseFilename=Armadito-Agent-{#MyAppVersion}
Compression=lzma
SolidCompression=yes
ArchitecturesInstallIn64BitMode=x64
SetupLogging=yes
PrivilegesRequired=admin
SetupIconFile=res\armadito_192x192.ico
MinVersion=0,6.1

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files]
Source: "lib\*"; DestDir: "{app}\share\lib"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "etc\*"; DestDir: "{app}\etc"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\System\{#MyAppExeName}"; AppUserModelID: "TeclibSAS.ArmaditoAgent-F7E3EA05-C681-4087-940D-147654171532"     
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"