#!/bin/bash

set -ex

localDirectory="/usr/local/bin"
cd $localDirectory

dbName=$(echo $databaseName | tr "[:upper:]" "[:lower:]")

pgAdmin="host=$dataTierHost port=$dataTierPort sslmode=require user=$adminUsername password=$adminPassword dbname=postgres"
dbAdmin="host=$dataTierHost port=$dataTierPort sslmode=require user=$adminUsername password=$adminPassword dbname=$dbName"

databaseExists=$(psql "$pgAdmin" -t -c "select datname from pg_catalog.pg_database where lower(datname) = '$dbName'")
if [ ! $databaseExists ]; then
    psql "$pgAdmin" -c "create database $dbName"
    psql "$dbAdmin" -c "create user $databaseUsername with password '$databasePassword'"
    psql "$dbAdmin" -c "alter default privileges in schema public grant all privileges on tables to $databaseUsername"
    psql "$dbAdmin" -f opencue-bot-schema.sql
    psql "$dbAdmin" -f opencue-bot-data.sql
fi

systemService="opencue-bot.service"

dbUrl="jdbc:postgresql://$dataTierHost:$dataTierPort/$dbName?sslmode=require"
sed -i "/Environment=DB_URL/c Environment=DB_URL=$dbUrl" $systemService
sed -i "/Environment=DB_USER/c Environment=DB_USER=$databaseUsername" $systemService
sed -i "/Environment=DB_PASS/c Environment=DB_PASS=$databasePassword" $systemService
sed -i "/Environment=JAR_PATH/c Environment=JAR_PATH=$localDirectory/opencue-bot.jar" $systemService

cp $systemService /etc/systemd/system
systemctl enable $systemService
systemctl start $systemService
