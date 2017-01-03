@ECHO OFF

REM -- requirements :
REM -- wget https://eternallybored.org/misc/wget/

set version=0.1.0_02
set programpath=%~dp0\..
set strawberry_version=5.24.0.1

set download_url=http://strawberryperl.com/download/%strawberry_version%/strawberry-perl-%strawberry_version%-32bit.msi
if not exist %programpath%\res\strawberry-perl-%strawberry_version%-32bit.msi wget %download_url% -P %programpath%\res
copy "%programpath%\res\strawberry-perl-%strawberry_version%-32bit.msi" "%programpath%\res\strawberry-perl.msi"

REM -- call pl2bat %programpath%\bin\armadito-agent
"C:\Program Files (x86)\Inno Setup 5\iscc" /Qp /dMyAppVersion=%version% %programpath%\res\Armadito-Agent-Offline.iss