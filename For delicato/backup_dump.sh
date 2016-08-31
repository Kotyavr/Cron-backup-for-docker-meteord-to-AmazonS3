#!/bin/sh
#Include folders
APP_NAME="backup-S3"
DIR=/dump
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
#Check folder mongo and sync with Amazon S3 it exist
checkmongo(){
if [ -d $DIR/mongo ];
	then
	log "Check mongo dump dir pass!"
	log "Synchronize mongo_dump"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync $DIR/mongo/ s3://delicato.com.ua/dump/mongo/
	log "mongo_dump copyed"
else
	log "No mongo backup!"
fi
}
#Check folder images and sync with Amazon S3 it exist
checkimages(){
if 	[ -d $DIR/images ];
	then
	log "Check images dump dir pass!"
	log "Synchronize images_dump"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync $DIR/images/ s3://delicato.com.ua/dump/images/
	log "images_dump copyed"
else
	log "No images backup!"
fi
}
#Check folder for exiist and call functions upper this conf
checklogdir
if [ -d $DIR ];
then
	log "Check \"$DIR\" folder"
	checkmongo
	checkimages
	log "All data copyed"
	log "Removing temporary dump directories"
	rm -rf $DIR/mongo
	rm -rf $DIR/images
	log "Temporary \"dump\" directories removed"
else
	log "Nothing to backup"
	rm -rf $DIR/mongo
	rm -rf $DIR/images
	log "Temporary \"dump\" directories removed"
fi
log "All done! Logs in $LOGDIR" && exit

