#!/bin/bash

# Needed If not packaged
PREFIX=/usr/local

groupadd armaditoagent
useradd -g armaditoagent armaditoagent
chown armaditoagent:armaditoagent $PREFIX/var/armadito-agent
