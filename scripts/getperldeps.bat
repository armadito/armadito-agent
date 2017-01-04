@ECHO OFF

set programpath=%~dp0\..

REM -- cpan install Time::Piece INSTALL_BASE=%programpath%\out
cpanm --quiet --installdeps --notest -L %programpath%\out\perldeps ..\