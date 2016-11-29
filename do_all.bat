@echo off

call tidyall -a
perl Makefile.PL
dmake
dmake test
dmake install