; I-EVE-TITS Installer
; Inno Setup script for building Windows installer
; Download Inno Setup from: https://jrsoftware.org/isdl.php
; Usage: Right-click this file > Compile with Inno Setup, or use: iscc.exe setup.iss

[Setup]
AppName=I-EVE-TITS
AppVersion=1.0.0
AppPublisher=I-EVE-TITS Contributors
AppPublisherURL=https://github.com/yourusername/i-eve-tits
AppSupportURL=https://github.com/yourusername/i-eve-tits/issues
AppUpdatesURL=https://github.com/yourusername/i-eve-tits
DefaultDirName={localappdata}\I-EVE-TITS
DefaultGroupName=I-EVE-TITS
OutputBaseFilename=I-EVE-TITS-Setup
OutputDir=.\dist
AllowNoIcons=yes
LicenseFile=LICENSE
UninstallDisplayIcon={app}\icon.ico
Compression=lzma
SolidCompression=yes
PrivilegesRequired=admin
WizardStyle=modern
VersionInfoVersion=1.0.0
VersionInfoCompany=I-EVE-TITS
VersionInfoDescription=Industrial Eve Technology Information Tethering System
VersionInfoProductName=I-EVE-TITS
VersionInfoProductVersion=1.0.0

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Types]
Name: "full"; Description: "Full installation"
Name: "compact"; Description: "Compact installation (no SDE data)"
Name: "custom"; Description: "Custom installation"; Flags: iscustom

[Components]
Name: "app"; Description: "I-EVE-TITS Application"; Types: full compact custom; Flags: fixed
Name: "sde"; Description: "SDE Data (~500MB)"; Types: full; ExtraDiskSpaceRequired: 524288000
Name: "shortcuts"; Description: "Start Menu Shortcuts"; Types: full compact custom

[Files]
; Application files
Source: "docker-compose.yml"; DestDir: "{app}\repo"; Components: app
Source: "LICENSE"; DestDir: "{app}\repo"; Components: app
Source: "README.md"; DestDir: "{app}\repo"; Components: app
Source: "SETUP_WINDOWS.md"; DestDir: "{app}\repo"; Components: app
Source: ".github\*"; DestDir: "{app}\repo\.github"; Components: app; Flags: recursesubdirs
Source: "tests\*"; DestDir: "{app}\repo\tests"; Components: app; Flags: recursesubdirs
Source: "backend\*"; DestDir: "{app}\repo\backend"; Components: app; Flags: recursesubdirs
Source: "frontend\*"; DestDir: "{app}\repo\frontend"; Components: app; Flags: recursesubdirs

; Helper scripts
Source: "install.ps1"; DestDir: "{app}"; Components: app
Source: "scripts\start.ps1"; DestDir: "{app}"; Components: app
Source: "scripts\stop.ps1"; DestDir: "{app}"; Components: app
Source: "scripts\logs.ps1"; DestDir: "{app}"; Components: app

; SDE Data (optional)
Source: "eve-static-data\*.jsonl"; DestDir: "{app}\repo\eve-static-data"; Components: sde; Flags: createallsubdirs

[Dirs]
Name: "{app}\repo"
Name: "{app}\repo\eve-static-data"

[Icons]
Name: "{group}\Start I-EVE-TITS"; Filename: "{app}\start.bat"; Comment: "Start I-EVE-TITS services"; Components: shortcuts
Name: "{group}\Stop I-EVE-TITS"; Filename: "{app}\stop.bat"; Comment: "Stop I-EVE-TITS services"; Components: shortcuts
Name: "{group}\View Logs"; Filename: "{app}\logs.bat"; Comment: "View application logs"; Components: shortcuts
Name: "{group}\Open Dashboard"; Filename: "{app}\dashboard.bat"; Comment: "Open web dashboard"; Components: shortcuts
Name: "{group}\Configuration"; Filename: "{app}\repo\.env"; Comment: "Edit API credentials"; Components: shortcuts
Name: "{group}\Documentation"; Filename: "{app}\repo\README.md"; Comment: "Read documentation"; Components: shortcuts
Name: "{group}\Uninstall I-EVE-TITS"; Filename: "{uninstallexe}"; Components: shortcuts
Name: "{autodesktop}\I-EVE-TITS"; Filename: "{app}\dashboard.bat"; Comment: "Open I-EVE-TITS"; Components: shortcuts

[Run]
Filename: "powershell.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\setup.ps1"""; Description: "Configure and start I-EVE-TITS"; Flags: runhidden waituntilterminated

[UninstallDelete]
Type: dirifempty; Name: "{app}"

[Code]
const
  REGPATH = 'Software\I-EVE-TITS';

procedure CurPageChanged(CurPageID: Integer);
begin
  // Custom logic for installation wizard pages
  if CurPageID = wpFinished then
    WizardForm.FinishedHeadingLabel.Caption := 'Installation Complete!';
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  Result := True;
  
  if CurPageID = wpSelectComponents then
  begin
    // Warn if no components selected
    if not WizardSelectedComponents(False) then
    begin
      MsgBox('Please select at least one component to install.', mbInformation, MB_OK);
      Result := False;
    end;
  end;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  // Check for Docker
  if not FileExists('C:\Program Files\Docker\Docker\docker.exe') and
     not FileExists('C:\Program Files (x86)\Docker\Docker\docker.exe') then
  begin
    MsgBox('Docker Desktop is not installed.' + #13#13 +
           'Please install Docker Desktop first:' + #13 +
           'https://www.docker.com/products/docker-desktop' + #13#13 +
           'The installer will continue, but you will need Docker to run I-EVE-TITS.',
           mbWarning, MB_OK);
  end;
  
  Result := '';
  NeedsRestart := False;
end;

procedure DeinitializeSetup();
begin
  // Any cleanup after setup
end;

[Messages]
WizardWelcome=Welcome to the I-EVE-TITS setup wizard

[CustomMessages]
english.FinishedHeadingLabel=Installation Complete!
english.FinishedLabel=I-EVE-TITS has been installed successfully. You can start using it by clicking the shortcuts in the Start Menu.

