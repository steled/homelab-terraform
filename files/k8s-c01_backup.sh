#!/bin/bash

PORT=3
UNREACHABLE=1;
HOST=backup01
HOST_IP=172.16.4.20
FILE=/root/.ssh/known_hosts

# be sure that port is shutdown
echo -e "\033[41;106mRunning poe_script off\033[0m"

/ext/scripts/poe_script.sh off $PORT 2> /dev/null

if [ $? -eq 1 ]; then
  echo -e "\033[41;101mPort $PORT is not in shutdown mode\033[0m"
  exit 1
fi

echo -e "\n\033[41;106mRunning poe_script on\033[0m"

/ext/scripts/poe_script.sh on $PORT 2> /dev/null

grep -q backup01 /etc/hosts

if [ $? -eq 1 ]; then
  echo -e "\n\033[41;106mAdding backup01 to hosts file\033[0m"
  echo "172.16.4.20 backup01" | sudo tee -a /etc/hosts
fi

echo -e "\n\033[41;106mWaiting for boot of backup01\033[0m"

while [ $UNREACHABLE -ne "0" ]
  do
  ping $HOST -c 1 -W 2 2>&1 >/dev/null
  UNREACHABLE=$?
  sleep 1
done

# if [ ! -f "$FILE" ]; then
#   echo -e "\033[41;106mCreating file /root/.ssh/known_hosts\033[0m"
#   sudo touch $FILE
# fi

sudo ssh-keygen -l -F $HOST > /dev/null
if [ $? -eq 1 ]; then
  echo -e "\033[41;106mAdding SSH host keys to /root/.ssh/known_hosts\033[0m"
  sudo -- sh -c "ssh-keyscan -t rsa $HOST >> ~/.ssh/known_hosts" 2> /dev/null
  sudo -- sh -c "ssh-keyscan -t rsa $HOST_IP >> ~/.ssh/known_hosts" 2> /dev/null
fi

echo -e "\033[41;106mRunning rsync\033[0m"

sudo rsync --exclude 'jdownloader/downloads' --rsync-path="sudo rsync" --delete -ave "ssh -i /home/steled/.ssh/backup.id_rsa" /ext/ steled@$HOST:/ext/k8s-c01_backup/

#if [ ! -f ~/.ssh/known_hosts ]; then
#  echo -e "\033[41;106mRunning creating file ~/.ssh/known_hosts\033[0m"
#  touch ~/.ssh/known_hosts
#fi

ssh-keygen -l -F $HOST > /dev/null
if [ $? -ne 0 ]; then
  echo -e "\033[41;106mAdding SSH host keys to ~/.ssh/known_hosts\033[0m"
  ssh-keyscan -t rsa $HOST >> ~/.ssh/known_hosts 2> /dev/null
  ssh-keyscan -t rsa $HOST_IP >> ~/.ssh/known_hosts 2> /dev/null
fi

echo -e "\033[41;106mShutdown of backup01\033[0m"

ssh -i /home/steled/.ssh/backup.id_rsa -o ConnectTimeout=5 $HOST "sudo /sbin/shutdown -h now"

echo -e "\033[41;106mWaiting for shutdown of backup01\033[0m"

while [ $UNREACHABLE -ne "1" ]
  do
  ping $HOST -c 1 -W 2 2>&1 >/dev/null
  UNREACHABLE=$?
  sleep 1
done

echo -e "\033[41;106mRunning poe_script off\033[0m"

/ext/scripts/poe_script.sh off $PORT 2> /dev/null
