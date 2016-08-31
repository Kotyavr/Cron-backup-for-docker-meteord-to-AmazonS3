#!/bin/sh
#Include folders
APP_NAME="chme"	#(Your METEOR_APP name used for sorting logs)
DUMP_DIR=/my/dump/dir	#(cooperate with \'DOCKER_DUMP_DIR\' in backup_mongo.sh)
IMAGES_DUMP_DIR=$DUMP_DIR/images	#(cooperate with \'IMAGES_DUMP_DIR\' in backup_uploads.sh)
MONGO_DUMP_DIR=$DUMP_DIR/mongo	#(cooperate with \'MONGO_DUMP_DIR\' in backup_mongo.sh)
TIMESTAMP=`date +%F-%H%M`
LOG_NAME="$APP_NAME-$TIMESTAMP"
LOGDIR=/my/log/dir	#(dir which used for save script logs, can be different)
AMAZON_BUCKET_DIR=s3://mybucketname #(cooperate with your Amazon S3 dtorage bucket)

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
   echo $message >>$LOGDIR/$LOG_NAME
}
#Check folder mongo and sync with Amazon S3 it exist
checkmongo(){
if [ -d $MONGO_DUMP_DIR ];
	then
	log "Check mongo dump dir pass!"
	log "Synchronize mongo_dump"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync $MONGO_DUMP_DIR/ $AMAZON_DUMP_DIR/$MONGO_DUMP_DIR
	log "mongo_dump copyed"
else
	log "No mongo backup!"
fi
}
#Check folder images and sync with Amazon S3 it exist
checkimages(){
if 	[ -d $IMAGES_DUMP_DIR ];
	then
	log "Check images dump dir pass!"
	log "Synchronize images_dump"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync $IMAGES_DUMP_DIR/ $AMAZON_DUMP_DIR/$IMAGES_DUMP_DIR
	log "images_dump copyed"
else
	log "No images backup!"
fi
}
#Check folder for exiist and call functions upper this conf
checklogdir
if [ -d $DUMP_DIR ];
then
	log "Check \"$DUMP_DIR\" folder"
	checkmongo
	checkimages
	log "All data copyed"
	log "Removing temporary dump directories"
	rm -rf $MONGO_DUMP_DIR
	rm -rf $IMAGES_DUMP_DIR
	log "Temporary \"dump/...\" directories removed"
else
	log "Nothing to backup"
	rm -rf $MONGO_DUMP_DIR
	rm -rf $IMAGES_DUMP_DIR
	log "Temporary \"dump/...\" directories removed"
fi
log "All done! Logs in $LOGDIR" && exit

