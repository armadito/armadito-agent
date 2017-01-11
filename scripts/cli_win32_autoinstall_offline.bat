@ECHO OFF

set version=0.1.0_02
set programpath=%~dp0\..

%programpath%\out\Armadito-Agent-%version%-Setup-Offline.exe ^
    /SP- /VERYSILENT /LOG=%programpath%\out\setuplog.txt /KEY=AAAA-AAAA-AAAA-AAAA-AAAA

REM -- To change default install directory : /DIR=C:\Armadito-Agent
REM -- For further informations, see : http://www.jrsoftware.org/ishelp/index.php?topic=setupcmdline