#!/bin/bash
set -o pipefail

# sudo -u zabbix ./Zext_check_scan.sh -H 91.229.246.60 -p 22

PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

BASEDIR=/var/lib/zabbix
SCANDIR=$BASEDIR/scans
CHANGED=0
INITIAL=0

IP=$2
PORT="$4"

if [ ! "$IP" ]; then
   echo "No IP address supplied"
   exit 1
fi
if [ ! "$PORT" ]; then
  echo "No port supplied"
  exit 1
fi

if [ ! -d $BASEDIR ]; then
  mkdir -p $BASEDIR
fi
if [ ! -d $SCANDIR ]; then
  mkdir $SCANDIR
fi

if [ ! -f "$SCANDIR/${IP}_${PORT}.base" ]; then
  touch "$SCANDIR/${IP}_${PORT}.base"
  INITIAL=1
fi

netcat -w 1 -zv ${IP} ${PORT} 2>&1 | egrep -w " open$" > "${SCANDIR}/${IP}_${PORT}"

DIFF=$(comm -23 "${SCANDIR}/${IP}_${PORT}" "$SCANDIR/${IP}_${PORT}.base")
if [ -n "${DIFF}" ]; then
  CHANGED=1
fi

if [ $INITIAL -eq 1 ]; then
  cat "${SCANDIR}/${IP}_${PORT}" > "$SCANDIR/${IP}_${PORT}.base"
  echo "Initial scan"
  exit 0
fi

if [ $CHANGED -eq 1 ]; then
  echo "CRITICAL - Diff: $DIFF"
  exit 1
else
  echo "OK"
  exit 0
fi