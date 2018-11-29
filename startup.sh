#!/bin/bash

BASE_DIR=/opt/janus

PATH=/usr/local/sbin:/usr/local/bin:${PATH}
LD_LIBRARY_PATH=/usr/lib:/usr/lib64/mysql:${LD_LIBRARY_PATH}

# start kea-anterius (Web UI)
cd /root/kea-anterius
npm start &

# kea-ctrl-agent
/usr/local/sbin/kea-ctrl-agent -c /usr/local/etc/kea/kea-ctrl-agent.conf &

# kea-dhcp
/usr/local/sbin/kea-dhcp4 -c /usr/local/etc/kea/kea-dhcp4.conf
