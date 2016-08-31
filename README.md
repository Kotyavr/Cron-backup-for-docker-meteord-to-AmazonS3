# Cron-backup-for-docker-meteord-to-AmazonS3
Cron backup solution for docker-meteord to backup in AmazonS3

Install

1)For debian/ubuntu install amazon S3 on your server by using: apt-get install s3cmd
2)Install GnuPG by command: apt-get install gnupg
3)Use: s3cmd --configure , for cooperate you're server with amazon s3 service
4)Go to configure scripts (read comments)

How is scripts work

For correct using scripts start them wis this sequence:
backup_mongo or/and backup_uploads->backup_dump->uploads_restore or/and mongo_restore
Why is so: backup_dump.sh check repositories which creates by backup_mongo.sh and backup_uploads.sh,
then copy all data in that directories to amazon s3 and remove temp dir's. If he can't find directories, 
then he'll say 'nothing to restore' and ends
Script uploads_restore check image dir for exist and copyed data on it if no data(images) or dir isn't exist,
script create it and restore there data from amazon s3, else it sas nothing to restore all is OK fnl show result of count files in dir

PS: mongo_restore use one time for restore mongo and not need for cron task. Use it manual.
if you have any problems send me a message in akariume@gmail.com
Lang RU/UA/EN
