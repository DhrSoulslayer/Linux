#!/bin/bash

#DGet the new mirror url from the commandline input
aptmirror=$1
#Get the ubuntu codename for the running distribution
distro=$(cat /etc/os-release | grep UBUNTU_CODENAME | awk -F= '{ print $2 }')

#Backup current sources.list file
mv /etc/apt/sources.list /etc/apt/sources.list.backup

#Create new sources file and populate it with the new repo
touch /etc/apt/sources.list

cat <<EOT >> /etc/apt/sources.list
###### Ubuntu Main Repos
deb https://$aptmirror/ubuntu/ $distro main restricted universe multiverse 

###### Ubuntu Update Repos
deb https://$aptmirror/ubuntu/ $distro-security main restricted universe multiverse 
deb https://$aptmirror/ubuntu/ $distro-updates main restricted universe multiverse 
deb https://$aptmirror/ubuntu/ $distro-proposed main restricted universe multiverse 
deb https://$aptmirror/ubuntu/ $distro-backports main restricted universe multiverse 
EOT
#Check the new repository
apt update