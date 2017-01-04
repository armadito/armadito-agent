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
AllowNoIcons=yes
AllowRootDirectory=no
AllowUNCPath=no
AlwaysRestart=no
AlwaysShowComponentsList=yes
AlwaysUsePersonalGroup=yes
ArchitecturesInstallIn64BitMode=x64
Compression=lzma
DefaultDirName={pf}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=..\COPYING
MinVersion=0,6.1
OutputBaseFilename=Armadito-Agent-{#MyAppVersion}-Setup-Offline
Outputdir=..\out
OutputManifestFile=package-manifest.txt
PrivilegesRequired=admin
SolidCompression=yes
SetupIconFile=armadito_192x192.ico
UninstallDisplayIcon={app}\res\armadito_192x192.ico
SetupLogging=yes

[CustomMessages]
InstallPerlMessage=Install Strawberry perl distribution
InstallPerlDeps=Install missing Perl dependencies
InstallPerlDepsStatus=Installing Perl dependencies...
InstallPerlCpanM=Installing CpanMinus...

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"

[Tasks]
Name: "installperl"; Description: "{cm:InstallPerlMessage}";
Name: "installperldeps"; Description: "{cm:InstallPerlDeps}";

[Run]
Filename: "msiexec"; WorkingDir: "{app}"; \
    StatusMsg: "{cm:InstallPerlDepsStatus}"; Tasks: installperl; \
    Parameters: " /i ""{tmp}\strawberry-perl.msi"" /log ""{app}\installperl.log"" /quiet"; Flags: waituntilterminated

[Files]
Source: "..\res\*.ico"; DestDir: "{app}\res"; \
    Flags: ignoreversion;
Source: "..\lib\*"; DestDir: "{app}\lib"; \
    Flags: ignoreversion recursesubdirs createallsubdirs;
Source: "..\etc\agent.cfg"; DestDir: "{app}\etc"; DestName: "agent.cfg.new"; Check: IsConfExisting(); \
    Flags: ignoreversion recursesubdirs createallsubdirs;
Source: "..\etc\agent.cfg";  DestDir: "{app}\etc"; DestName: "agent.cfg"; Check: not IsConfExisting(); \
    Flags: ignoreversion recursesubdirs createallsubdirs uninsneveruninstall;
Source: "..\bin\*"; DestDir: "{app}\bin"; \
    Flags: ignoreversion recursesubdirs createallsubdirs;
Source: "..\res\strawberry-perl.msi"; DestDir: "{tmp}"; \
    Flags: ignoreversion; Tasks: installperl

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\System\{#MyAppExeName}"; \
    AppUserModelID: "TeclibSAS.ArmaditoAgent-F7E3EA05-C681-4087-940D-147654171532"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Registry]
Root: HKCU; Subkey: "Software\Armadito-Agent"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\Armadito-Agent"; \
    ValueType: string; ValueName: "PerlPath"; ValueData: "{code:GetPerlPath}"
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}\bin"; \
    Check: NeedsAddEnvVariable('{app}\bin', 'Path')
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "PERL5LIB"; ValueData: "{olddata};{app}\lib"; \
    Check: NeedsAddEnvVariable('{app}\lib', 'PERL5LIB')

[UninstallDelete]
Type: files; Name: "{app}\Makefile"
Type: files; Name: "{app}\MYMETA.*"
Type: files; Name: "{app}\META.yml"
Type: files; Name: "{app}\installcpanm.log"
Type: files; Name: "{app}\installdeps.log"
Type: filesandordirs; Name: "{app}\inc"
Type: dirifempty; Name: "{app}\var"

[Code]
var
  PerlPathPage: TInputDirWizardPage;

function NeedsAddEnvVariable(Param: String; EnvVar: String): Boolean;
var
  OrigPath: String;
begin
  Param := ExpandConstant(Param);

  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    EnvVar, OrigPath)
  then begin
    Result := True;
    Exit;
  end;
  { look for the path with leading and trailing semicolon }
  { Pos() returns 0 if not found }
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;

function IsConfExisting(): Boolean;
var
  ConfFile: String;
begin
  ConfFile := ExpandConstant('{app}\etc\agent.cfg');

  if FileExists(ConfFile)
  then begin
    Result := True;
    Exit;
  end;

  Result := False;
end;

procedure AboutButtonOnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExecAsOriginalUser('open', 'http://armadito-glpi.readthedocs.io/en/dev', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure URLLabelOnClick(Sender: TObject);
var
  ErrorCode: Integer;
begin
  ShellExecAsOriginalUser('open', 'http://www.armadito.com/', '', '', SW_SHOWNORMAL, ewNoWait, ErrorCode);
end;

procedure CreateAboutButtonAndURLLabel(ParentForm: TSetupForm; CancelButton: TNewButton);
var
  AboutButton: TNewButton;
  URLLabel: TNewStaticText;
begin
  AboutButton := TNewButton.Create(ParentForm);
  AboutButton.Left := ParentForm.ClientWidth - CancelButton.Left - CancelButton.Width;
  AboutButton.Top := CancelButton.Top;
  AboutButton.Width := CancelButton.Width;
  AboutButton.Height := CancelButton.Height;
  AboutButton.Caption := '&About...';
  AboutButton.OnClick := @AboutButtonOnClick;
  AboutButton.Parent := ParentForm;

  URLLabel := TNewStaticText.Create(ParentForm);
  URLLabel.Caption := 'www.armadito.com';
  URLLabel.Cursor := crHand;
  URLLabel.OnClick := @URLLabelOnClick;
  URLLabel.Parent := ParentForm;
  { Alter Font *after* setting Parent so the correct defaults are inherited first }
  URLLabel.Font.Style := URLLabel.Font.Style + [fsUnderline];
  if GetWindowsVersion >= $040A0000 then   { Windows 98 or later? }
    URLLabel.Font.Color := clHotLight
  else
    URLLabel.Font.Color := clBlue;
  URLLabel.Top := AboutButton.Top + AboutButton.Height - URLLabel.Height - 2;
  URLLabel.Left := AboutButton.Left + AboutButton.Width + ScaleX(20);
end;

procedure CreatePerlPathPage();
begin

  PerlPathPage := CreateInputDirPage(wpSelectTasks,
  'Select a path where perl will be installed', 'Strawberry Perl installation',
  '', False, 'New Folder');

  PerlPathPage.Add('Select an existing or new directory :');
  PerlPathPage.Values[0] := GetPreviousData('PerlPath', 'C:\Perl');

  if ExpandConstant('{param:PERLPATH|false}') <> 'false' then
  begin
    PerlPathPage.Values[0] := ExpandConstant('{param:PERLPATH}');
  end;

end;

procedure CreateBottomPanel();
var
  BackgroundBitmapImage: TBitmapImage;
  BackgroundBitmapText: TNewStaticText;
begin

  CreateAboutButtonAndURLLabel(WizardForm, WizardForm.CancelButton);

  BackgroundBitmapImage := TBitmapImage.Create(MainForm);
  BackgroundBitmapImage.Left := 50;
  BackgroundBitmapImage.Top := 90;
  BackgroundBitmapImage.AutoSize := True;
  BackgroundBitmapImage.Bitmap := WizardForm.WizardBitmapImage.Bitmap;
  BackgroundBitmapImage.Parent := MainForm;

  BackgroundBitmapText := TNewStaticText.Create(MainForm);
  BackgroundBitmapText.Left := BackgroundBitmapImage.Left;
  BackgroundBitmapText.Top := BackgroundBitmapImage.Top + BackgroundBitmapImage.Height + ScaleY(8);
  BackgroundBitmapText.Caption := 'TBitmapImage';
  BackgroundBitmapText.Font.Color := clWhite;
  BackgroundBitmapText.Parent := MainForm;
end;

procedure InitializeWizard();
begin
  CreatePerlPathPage();
  CreateBottomPanel();
end;

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'PerlPath', PerlPathPage.Values[0]);
end;

function isPerlInstalled(PerlPath: String): Boolean;
begin
  if FileExists(PerlPath + '\bin\cpan.bat') then begin
    Result := True;
  end else if FileExists(PerlPath + '\perl\bin\cpan.bat') then begin
    Result := True;
  end else begin
    Result := False;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = PerlPathPage.ID then begin
    if isPerlInstalled(PerlPathPage.Values[0]) then begin
      MsgBox('Perl already installed in '+ PerlPathPage.Values[0], mbError, MB_OK);
      Result := False;
    end else begin
      Result := True;
    end;
  end else begin
    Result := True;
  end;
end;

function GetPerlPath(Param: String): String;
begin
  Result := PerlPathPage.Values[0];
end;