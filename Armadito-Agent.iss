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
LicenseFile=COPYING
MinVersion=0,6.1
OutputBaseFilename=Armadito-Agent-{#MyAppVersion}-Setup
Outputdir=out
OutputManifestFile=package-manifest.txt
PrivilegesRequired=admin
SolidCompression=yes
SetupIconFile=res\armadito_192x192.ico
UninstallDisplayIcon={app}\armadito_192x192.ico
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
Name: "installperldeps"; Description: "{cm:InstallPerlDeps}";

[Run]
Filename: "{code:GetPerlPath}\bin\cpan.bat"; WorkingDir: "{app}"; StatusMsg: "{cm:InstallPerlCpanM}"; Tasks: installperldeps; Parameters: "App::cpanminus > ""{app}\installcpanm.log"" 2>&1"; Flags: runhidden waituntilidle
Filename: "{code:GetPerlPath}\site\bin\cpanm.bat"; WorkingDir: "{app}"; StatusMsg: "{cm:InstallPerlDepsStatus}"; Tasks: installperldeps; Parameters: "--installdeps --notest . > ""{app}\installdeps.log"" 2>&1"; Flags: runhidden waituntilidle

[Files]
Source: "res\*.ico"; DestDir: "{app}"; Flags: ignoreversion;
Source: "lib\*"; DestDir: "{app}\lib"; Flags: ignoreversion recursesubdirs createallsubdirs;
Source: "etc\*"; DestDir: "{app}\etc"; Flags: ignoreversion recursesubdirs createallsubdirs;
Source: "bin\*"; DestDir: "{app}\bin"; Flags: ignoreversion recursesubdirs createallsubdirs;
Source: "Makefile.PL"; DestDir: "{app}"; Flags: ignoreversion; Tasks: installperldeps

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\System\{#MyAppExeName}"; AppUserModelID: "TeclibSAS.ArmaditoAgent-F7E3EA05-C681-4087-940D-147654171532"     
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"


[Registry]
Root: HKCU; Subkey: "Software\Armadito-Agent"; Flags: uninsdeletekeyifempty
Root: HKCU; Subkey: "Software\Armadito-Agent"; ValueType: string; ValueName: "PerlPath"; ValueData: "{code:GetPerlPath}"

[Code]
var
  PerlPathPage: TInputDirWizardPage;

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

procedure InitializeWizard();
var
  BackgroundBitmapImage: TBitmapImage;
  BackgroundBitmapText: TNewStaticText;
begin
  { Custom pages }
  PerlPathPage := CreateInputDirPage(wpLicense,
  'Select an Installed Perl distribution', 'Perl > 5.8 is required',
  'Armadito-Agent requires perl to be installed. '#13#10#13#10 +
  'Please, select a path of an existing perl distribution :',
  False, 'New Folder');

  PerlPathPage.Add('Examples: C:\Perl, C:\ActivePerl, C:\strawberry\perl, etc');
  PerlPathPage.Values[0] := GetPreviousData('PerlPath', 'C:\');

  { Custom controls }
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

procedure RegisterPreviousData(PreviousDataKey: Integer);
begin
  SetPreviousData(PreviousDataKey, 'PerlPath', PerlPathPage.Values[0]);
end;

function SetPerlPath(PerlPath: String): Boolean;
begin
  if FileExists(PerlPath + '\bin\cpan.bat') then begin
    Result := True;
  end else if FileExists(PerlPath + '\perl\bin\cpan.bat') then begin
    PerlPathPage.Values[0] := PerlPath + '\perl';
    Result := True;
  end else begin
    Result := False;
  end;
end;

function NextButtonClick(CurPageID: Integer): Boolean;
var
  I: Integer;
begin
  if CurPageID = PerlPathPage.ID then begin
    if not SetPerlPath(PerlPathPage.Values[0]) then begin
      MsgBox('You must enter a valid perl distribution path', mbError, MB_OK);
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
  { Return the selected PerlPath}
  Result := PerlPathPage.Values[0];
end;