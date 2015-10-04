#!/bin/bash
#

# make sure the logfile exists and has teh right permissions
mkdir -p /var/log/etherpad/
chown -R etherpad:etherpad /var/log/etherpad

# run etherpad
exec su -c "/opt/etherpad/bin/run.sh" etherpad