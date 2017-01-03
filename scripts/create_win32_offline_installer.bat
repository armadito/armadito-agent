@ECHO OFF

REM -- requirements :
REM -- wget https://eternallybored.org/misc/wget/

set version=0.1.0_02
set programpath=%~dp0\..
set strawberry_version=5.24.0.1

set download_url=http://strawberryperl.com/download/%strawberry_version%/strawberry-perl-%strawberry_version%-32bit-portable.zip
if not exist %programpath%\scripts\strawberry-perl-%strawberry_version%-32bit-portable.zip wget %download_url%

REM -- call pl2bat %programpath%\bin\armadito-agent
REM -- "C:\Program Files (x86)\Inno Setup 5\iscc" /Qp /dMyAppVersion=%version% %programpath%\res\Armadito-Agent-Offline.iss