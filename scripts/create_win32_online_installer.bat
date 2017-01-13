@ECHO OFF

set version=0.1.0_02
set programpath=%~dp0\..

call pl2bat %programpath%\bin\armadito-agent

"C:\Program Files (x86)\Inno Setup 5\iscc" /Qp /dMyAppVersion=%version% %programpath%\packaging\windows\Armadito-Agent-Online.iss
