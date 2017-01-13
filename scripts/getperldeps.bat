@ECHO OFF

set programpath=%~dp0\..

cpanm --quiet --installdeps --notest -L %programpath%\out\perldeps ..\