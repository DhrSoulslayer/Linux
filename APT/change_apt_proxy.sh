#!/bin/bash

#Take repo hostname or ip as input
repohost=$1

touch /etc/apt/apt.conf.d/01-aptproxy

cat <<EOT >> /etc/apt/apt.conf.d/01-aptproxy
Acquire::http::Proxy "http://$repohost:3142";
EOT