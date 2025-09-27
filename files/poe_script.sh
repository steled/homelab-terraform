#!/bin/bash

HOST=172.16.3.29
FILE=known_hosts

if [ ! -f "$FILE" ]; then
  sudo touch /root/.ssh/$FILE
fi

sudo ssh-keygen -l -F $HOST > /dev/null
if [ $? -eq 1 ]; then
#  sudo ssh-keyscan -t rsa $HOST >> ~/.ssh/known_hosts
  sudo -- sh -c "ssh-keyscan -t rsa $HOST >> ~/.ssh/known_hosts"
#  ssh-keyscan -t rsa $HOST >> ~/.ssh/known_hosts
fi

poweron_all()
{
nc 127.0.0.1 23 << END
enable
configure
interface 0/6
poe opmode auto
interface 0/7
poe opmode auto
interface 0/8
poe opmode auto
exit
exit
exit
exit
END
}

poweron()
{
nc 127.0.0.1 23 << END
enable
configure
interface 0/$1
poe opmode auto
exit
exit
exit
exit
END
}

poweroff_all()
{
nc 127.0.0.1 23 << END
enable
configure
interface 0/6
poe opmode shutdown
interface 0/7
poe opmode shutdown
interface 0/8
poe opmode shutdown
exit
exit
exit
exit
END
}

poweroff()
{
nc 127.0.0.1 23 << END
enable
configure
interface 0/$1
poe opmode shutdown
exit
exit
exit
exit
END
}

sudo sshpass -p 'ubnt' ssh -N -L 23:127.0.0.1:23 ubnt@$HOST &
sleep 5

if [ "$1" == "on" ] && [ "$2" == "all" ]; then
  poweron_all
elif [ "$1" == "off" ] && [ "$2" == "all" ]; then
  poweroff_all
elif [ "$1" == "on" ] && [ "$2" != "" ]; then
  poweron $2
elif [ "$1" == "off" ] && [ "$2" != "" ]; then
  poweroff $2
fi

sudo kill $(pgrep -f ubnt)
