@echo off

perl Makefile.PL
dmake
REM dmake test
dmake install