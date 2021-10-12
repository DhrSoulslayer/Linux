#!/bin/bash
ipstart=$(ipcalc $1 | grep HostMin | awk '{print $2}')
ipend=$(ipcalc $1 | grep HostMax | awk '{print $2}')

ipstartoct1=$(echo $ipstart | awk -F "." '{print $1}')
ipstartoct2=$(echo $ipstart | awk -F "." '{print $2}')
ipstartoct3=$(echo $ipstart | awk -F "." '{print $3}')
ipstartoct4=$(echo $ipstart | awk -F "." '{print $4}')

ipendoct1=$(echo $ipend | awk -F "." '{print $1}')
ipendoct2=$(echo $ipend | awk -F "." '{print $2}')
ipendoct3=$(echo $ipend | awk -F "." '{print $3}')
ipendoct4=$(echo $ipend | awk -F "." '{print $4}')

while [ $ipstartoct4 -le $ipendoct4 ]
do
  echo $ipstartoct1.$ipstartoct2.$ipstartoct3.$ipstartoct4 >> list.txt
  ipstartoct4=$(($ipstartoct4 + 1))
done
