#!/bin/bash
set -e

apk add --no-cache docker-cli

# Wait for Nextcloud to be fully up and running
echo "Waiting for Nextcloud to be fully up and running..."
sleep 20

NEXTCLOUD_CONTAINER="nc"

# Disable brute-force protection. This is useful in a testing environment to avoid lockouts.
echo "Disabling brute-force protection..."
docker exec -u www-data $NEXTCLOUD_CONTAINER php occ config:system:set bruteforce.protection.enabled --value=false --type=bool
echo "brute-force protection disabled ✅"

# Creation of the QA user.
echo "Creating QA user..."
docker exec -u www-data $NEXTCLOUD_CONTAINER sh -c 'export OC_PASS="qasecretpass"; php occ user:add --password-from-env --display-name="QA User" qauser'
echo "QA user created ✅"

# Creation of the group and adding the QA user to it
echo "Creating testers group and adding QA user to it..."
docker exec -u www-data $NEXTCLOUD_CONTAINER php occ group:add testers
docker exec -u www-data $NEXTCLOUD_CONTAINER php occ group:adduser testers qauser
echo "Testers group created and QA user added to it ✅"

# Load a txt file into the QA user's files
# mkdir -p data/qauser/files
# echo "Hello World" > data/qauser/files/readme.txt
echo "Uploading a sample file to the QA user's files..."
docker exec -u www-data $NEXTCLOUD_CONTAINER mkdir -p /var/www/html/data/qauser/files
docker exec -u www-data $NEXTCLOUD_CONTAINER sh -c 'echo "Hello World" > /var/www/html/data/qauser/files/readme.txt'
echo "Sample file uploaded ✅"
echo "Bootstrap finished ✅"