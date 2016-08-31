#!/bin/sh
#Include folders
APP_NAME="uploadsrestore"
DIR=/opt/spectre/current/bundle
TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="$APP_NAME-$TIMESTAMP"
LOGDIR=/dumplog

checklogdir(){
if [ -d $LOGDIR ];
then
	echo "Log folder exist"
else
	echo "No such log folder was found"
	mkdir $LOGDIR
	echo "Log folder was created"
fi
}
#Log messages to file
log(){
   message="$(date +"%y-%m-%d %T") $@"
   echo $message
   echo $message >>$LOGDIR/$BACKUP_NAME
}
#Check folder and files, if some of it gone, then sync it from Amazon S3
checklogdir
if [ -d $DIR/.uploads ];
then
 log "Dir \"$DIR/.uploads\" exists"
	filecount=`find $DIR/.uploads -type f | wc -l`
		if [ $filecount -eq 0 ];
		then
			log "No files in .uploads"
			log "Synchronize"
			log "Copy start"
			s3cmd --acl-private --bucket-location=EU --guess-mime-type sync s3://delicato.com.ua/uploadsrestore/  $DIR/.uploads/
			log "Image data restored from Amazon S3"
			log "All done! Logs in $LOGDIR" && exit
		else
			log "Check pass!"
			log "In folder  \"$DIR/.uploads\" $filecount files"
       			log "Image data do not need to be restored"
    			log "All done! Logs in $LOGDIR" && exit
		fi
else
	log ".uploads not existed. Crearing..."
	mkdir $DIR/.uploads
	log "Dir \"$DIR/.uploads\" created"
	log "Synchronize"
	log "Copy start"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync s3://delicato.com.ua/uploadsrestore/  $DIR/.uploads/
fi
	log "Image data restored from Amazon S3"
	log "All done! Logs in $LOGDIR" && exit

