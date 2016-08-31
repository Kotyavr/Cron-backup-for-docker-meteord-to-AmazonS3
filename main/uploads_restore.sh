#!/bin/sh
#Include folders
APP_NAME="chme"	#(Your METEOR_APP name used for sorting logs)
APP_DIR=/your/app/deploing/folder/	#(Your METEOR_APP deploy dir)
TIMESTAMP=`date +%F-%H%M`
LOG_NAME="$APP_NAME-$TIMESTAMP"
BACKUP_DIR_NAME="nameyourimagedir"	#(cooperate with 'MONGO_DUMP_DIR' in backup_dump.sh)
LOGDIR=/my/log/dir	#(dir which used for save script logs, can be different)
AMAZON_DIR=s3://mybucketname/uploadsrestore	#(cooperate with your Amazon S3 dtorage bucket)

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
   message="$TIMESTAMP $@"
   echo $message
   echo $message >>$LOGDIR/$LOG_NAME
}
#Check folder and files, if some of it gone, then sync it from Amazon S3
checklogdir
if [ -d $APP_DIR/$BACKUP_DIR_NAME ];
then
 log "Dir \"$APP_DIR/$BACKUP_DIR_NAME\" exists"
	filecount=`find $APP_DIR/$BACKUP_DIR_NAME -type f | wc -l`
		if [ $filecount -eq 0 ];
		then
			log "No files in $BACKUP_DIR_NAME"
			log "Synchronize"
			log "Copy start"
			s3cmd --acl-private --bucket-location=EU --guess-mime-type sync s3:/$AMAZON_DIR/  $APP_DIR/$BACKUP_DIR_NAME/
			log "Image data restored from Amazon S3"
			log "All done! Logs in $LOGDIR" && exit
		else
			log "Check pass!"
			log "In folder  \"$APP_DIR/$BACKUP_DIR_NAME\" $filecount files"
       			log "Image data do not need to be restored"
    			log "All done! Logs in $LOGDIR" && exit
		fi
else
	log "$BACKUP_DIR_NAME not existed. Crearing..."
	mkdir $APP_DIR/$BACKUP_DIR_NAME
	log "Dir \"$APP_DIR/$BACKUP_DIR_NAME\" created"
	log "Synchronize"
	log "Copy start"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync $AMAZON_DIR/  $APP_DIR/$BACKUP_DIR_NAME/
fi
	log "Image data restored from Amazon S3"
	log "All done! Logs in $LOGDIR" && exit

