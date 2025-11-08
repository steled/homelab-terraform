#!/bin/bash

hassio=172.16.3.20
backup_dir=/ext/backups/hassio/

# if [ ! -f ~/.ssh/known_hosts ]; then
#     touch ~/.ssh/known_hosts
# fi

ssh-keygen -l -F $hassio > /dev/null
if [ $? -ne 0 ]; then
  echo -e "\033[41;106mAdding SSH host keys to ~/.ssh/known_hosts\033[0m"
  ssh-keyscan -t rsa $hassio >> ~/.ssh/known_hosts 2> /dev/null
fi

# create new snapshot remotely
echo -e "\033[41;106mCreating backup at hassio\033[0m"
ssh -o "IdentitiesOnly=yes" -i ~/.ssh/backup.id_rsa hassio@$hassio 'source /etc/profile; ha backups new' 2> /dev/null

# use rsync to copy only archives that dont already exist on local
echo -e "\033[41;106mSyncing backup to local\033[0m"
rsync --delete -rtu -e "ssh -o \"IdentitiesOnly=yes\" -i ~/.ssh/backup.id_rsa" hassio@$hassio:/backup/ $backup_dir 2> /dev/null


# delete backups older than 6 days to save disk space
echo -e "\033[41;106mDeleting old backups\033[0m"
ssh -o "IdentitiesOnly=yes" -i ~/.ssh/backup.id_rsa hassio@$hassio "sudo find /backup/ -type f -name '*.tar' -mtime +6 -exec rm {} \;" 2> /dev/null
