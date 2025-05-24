# get vars
# POD_SERVER=$(kubectl get pods -n nextcloud -l app.kubernetes.io/component=app --no-headers -o custom-columns=NAME:metadata.name)
POD_DB=$(kubectl get pods -n nextcloud -l app.kubernetes.io/component=primary --no-headers -o custom-columns=NAME:metadata.name)

# activate maintenance mode
# kubectl exec -n nextcloud $POD_SERVER -c nextcloud -- bash -c "su -s /bin/bash www-data -c 'php occ maintenance:mode --on'"

# scale deployment to 0 replicas
kubectl scale deployment -n nextcloud nextcloud --replicas 0

# run edit pod
kubectl run -n=nextcloud -i --rm --tty ubuntu --overrides='{
  "apiVersion": "v1",
  "spec": {
    "containers": [
      {
        "name": "ubuntu",
        "image": "ubuntu",
        "args": [
          "bash"
        ],
        "stdin": true,
        "stdinOnce": true,
        "tty": true,
        "volumeMounts": [
          {
            "mountPath": "/ext",
            "name": "nextcloud-main"
          }
        ]
      }
    ],
    "volumes": [
      {
        "name": "nextcloud-main",
        "persistentVolumeClaim": {
          "claimName": "nextcloud-nextcloud"
        }
      }
    ]
  }
}
'  --image=ubuntu --restart=Never -- bash

# server

# kubectl exec -n nextcloud $POD_SERVER -- bash -c "rm /var/www/html/config/.htaccess /var/www/html/config/apache-pretty-urls.config.php /var/www/html/config/apcu.config.php /var/www/html/config/apps.config.php /var/www/html/config/autoconfig.php /var/www/html/config/custom.config.php /var/www/html/config/redis.config.php /var/www/html/config/reverse-proxy.config.php /var/www/html/config/s3.config.php /var/www/html/config/smtp.config.php /var/www/html/config/swift.config.php /var/www/html/config/upgrade-disable-web.config.php"
# kubectl exec -n nextcloud ubuntu -- bash -c "rm /var/www/html/config/.htaccess /var/www/html/config/apache-pretty-urls.config.php /var/www/html/config/apcu.config.php /var/www/html/config/apps.config.php /var/www/html/config/autoconfig.php /var/www/html/config/custom.config.php /var/www/html/config/redis.config.php /var/www/html/config/reverse-proxy.config.php /var/www/html/config/s3.config.php /var/www/html/config/smtp.config.php /var/www/html/config/swift.config.php /var/www/html/config/upgrade-disable-web.config.php"
# kubectl cp ext/backup/nextcloud/server/html nextcloud/$POD_SERVER:/var/www/ --no-preserve
# kubectl cp ext/backup/nextcloud/server/config nextcloud/$POD_SERVER:/var/www/html --no-preserve
# kubectl cp ext/backup/nextcloud/server/custom_apps nextcloud/$POD_SERVER:/var/www/html --no-preserve
# kubectl cp ext/backup/nextcloud/server/data nextcloud/$POD_SERVER:/var/www/html --no-preserve
# kubectl cp ext/backup/nextcloud/server/themes nextcloud/$POD_SERVER:/var/www/html --no-preserve
kubectl cp ext/backup/nextcloud/server nextcloud/ubuntu:/ext --no-preserve


# database
## remove and recreate database before restore
kubectl exec -n nextcloud $POD_DB -- bash -c "PGPASSWORD=\$POSTGRES_PASSWORD psql -d template1 -h localhost -U nextcloud -c 'DROP DATABASE nextcloud;'"
kubectl exec -n nextcloud $POD_DB -- bash -c "PGPASSWORD=\$POSTGRES_PASSWORD psql -d template1 -h localhost -U nextcloud -c 'CREATE DATABASE nextcloud;'"

# restore database
kubectl cp nextcloud-sqlbkp_2025-02-05.bak nextcloud/$POD_DB:/tmp/nextcloud-sqlbkp.bak
kubectl exec -n nextcloud $POD_DB -- bash -c "PGPASSWORD=\$POSTGRES_PASSWORD psql -d nextcloud -h localhost -U nextcloud -q -f /tmp/nextcloud-sqlbkp.bak"
kubectl exec -n nextcloud $POD_DB -- bash -c "rm /tmp/nextcloud-sqlbkp.bak"

# scale deployment to 1 replicas
kubectl scale deployment -n nextcloud nextcloud --replicas 1


# deactivate maintenance mode
kubectl exec -n nextcloud $POD_SERVER -c nextcloud -- bash -c "su -s /bin/bash www-data -c 'php occ maintenance:mode --off'"

# restart pod
# kubectl exec -n nextcloud $POD_SERVER -c nextcloud -- bash -c "kill 1"


# update

## get vars
POD_SERVER=$(kubectl get pods -n nextcloud -l app.kubernetes.io/component=app --no-headers -o custom-columns=NAME:metadata.name)

# activate maintenance mode
kubectl exec -n nextcloud $POD_SERVER -c nextcloud -- bash -c "su -s /bin/bash www-data -c 'php occ maintenance:mode --on'"

## run upgrade
kubectl exec -n nextcloud $POD_SERVER -c nextcloud -- bash -c "su -s /bin/bash www-data -c 'php occ upgrade'"

## deactivate maintenance mode
kubectl exec -n nextcloud $POD_SERVER -c nextcloud -- bash -c "su -s /bin/bash www-data -c 'php occ maintenance:mode --off'"