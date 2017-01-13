#!/bin/sh

set -e

tidyall -a
perl Makefile.PL
make
make test
sudo make install
