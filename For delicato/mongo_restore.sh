#!/bin/sh
#Include folders
APP_NAME="mongodump"
DUMP_NAME="spectre"
DIR=/dump
TIMESTAMP=`date +%F-%H%M` BACKUP_NAME="$APP_NAME-$TIMESTAMP"
LOGDIR=/dumplog
DUMP_DIR=$DIR/mongo

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
   #check the dump folder, create if not exist
   checkdir(){
if [ -d $DUMP_DIR ];
	then
	rm -rf $DUMP_DIR
	mkdir $DUMP_DIR
	log "\"$DUMP_DIR\" folder renew"
	else
	log "No such \"$DUMP_DIR\" folder was found"
	mkdir $DUMP_DIR
	log "\"$DUMP_DIR\" folder was created"
	fi
	}
	syncmongo(){
if [ -d $DUMP_DIR ];
	then
	log "Check mongo dump folder pass!"
	log "Synchronize mongo_dump from Amazon S3"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync s3://delicato.com.ua/mongorestore/ $DUMP_DIR/$DUMP_NAME
	log "mongo_dump restored from Amazon S3"
fi
}
	#do the docker dump and copy it to dump folder
checklogdir
checkdir
syncmongo

if [ -d $DUMP_DIR/$DUMP_NAME ]; then
	docker cp $DUMP_DIR/ mongodb:$DIR/
	log "Mongo dump copyed to temp dir on docker"
	else
	log "Error folder not copyed, check original folder for exist"
	fi
log "Start mongorestore"
docker exec -it mongodb mongorestore --drop
log "restored"
rm -rf $DUMP_DIR/$DUMP_NAME
docker exec -it mongodb rm -rf /dump
log "Temporary mongo dump dirs removed"
log "All done! Logs in \"$LOGDIR\"" && exit


