#!/bin/sh

set -e

tidyall -a
perl Makefile.PL
make
sudo make test
sudo make install
