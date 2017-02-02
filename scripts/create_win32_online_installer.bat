@ECHO OFF

set version=0.10.1
set programpath=%~dp0\..

call pl2bat %programpath%\bin\armadito-agent

"C:\Program Files (x86)\Inno Setup 5\iscc" /Qp /dMyAppVersion=%version% %programpath%\packaging\Armadito-Agent-Online.iss
