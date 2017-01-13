@echo off

REM call tidyall -a
perl Makefile.PL
dmake
dmake test
dmake install