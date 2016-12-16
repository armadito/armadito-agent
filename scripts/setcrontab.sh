#!/bin/bash

VERSION=0.1

USER=root
AGENT=/usr/local/bin/armadito-agent
LOG_FILE=/tmp/armadito-agent.log

ALERT='01,11,21,31,41,51 * * * *    '$USER'    '$AGENT' -t "Alerts" >>'$LOG_FILE' 2>&1'
STATE='00,20,40 * * * *    '$USER'    '$AGENT' -t "State" >>'$LOG_FILE' 2>&1'
GETJOBS='* * * * *    '$USER'    '$AGENT' -t "Getjobs" >>'$LOG_FILE' 2>&1'

RUNJOBS_URGENT='* * * * *    '$USER'    '$AGENT' -t "Runjobs" -p 3 -w 5 >>'$LOG_FILE' 2>&1'
RUNJOBS_HIGH='*/2 * * * *    '$USER'    '$AGENT' -t "Runjobs" -p 2 -w 10 >>'$LOG_FILE' 2>&1'
RUNJOBS_MEDIUM='*/5 * * * *    '$USER'    '$AGENT' -t "Runjobs" -p 1 -w 15 >>'$LOG_FILE' 2>&1'
RUNJOBS_LOW='*/10 * * * *    '$USER'    '$AGENT' -t "Runjobs" -p 0 -w 30 >>'$LOG_FILE' 2>&1'

DATE=`date +%Y-%m-%d:%H:%M:%S`

echo '#
# Cron jobs for armadito-agent
#
# File automatically generated by setcrontab.sh script version '$VERSION'
# Creation date: '$DATE'
' > /etc/cron.d/armadito-agent

echo "$GETJOBS" >> /etc/cron.d/armadito-agent
echo "$RUNJOBS_URGENT" >> /etc/cron.d/armadito-agent
echo "$RUNJOBS_HIGH" >> /etc/cron.d/armadito-agent
echo "$RUNJOBS_MEDIUM" >> /etc/cron.d/armadito-agent
echo "$RUNJOBS_LOW" >> /etc/cron.d/armadito-agent
echo "$STATE" >> /etc/cron.d/armadito-agent
echo "$ALERT" >> /etc/cron.d/armadito-agent
