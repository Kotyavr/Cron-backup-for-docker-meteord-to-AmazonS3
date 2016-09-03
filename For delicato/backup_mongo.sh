#!/bin/sh
#Include folders
APP_NAME="mongodump"
DUMP_NAME="spectre"
DIR=/dump
TIMESTAMP=`date +%F-%H%M`
BACKUP_NAME="$APP_NAME-$TIMESTAMP"
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
	log "\"$DIR\" folder exist"
	else
	log "No such \"dump\" folder was found"
	mkdir $DUMP_DIR
	log "\"$DIR\" folder was created"
	fi
	}
	#do the docker dump and copy it to dump folder
checklogdir
checkdir
log "Start mongodump"
docker exec -it mongodb mongodump
log "Mongo dumped"
docker cp mongodb:$DIR/$DUMP_NAME/ $DUMP_DIR/$DUMP_NAME/
if [ -d $DUMP_DIR/$DUMP_NAME ]; then
	log "Mongo dump copyed to temp dir \"$DUMP_DIR/$DUMP_NAME\""
	else
	log "Error folder not copyed, check original folder for exist"
	fi
#archive mongo dump
tar -zcvf $DUMP_DIR/$DUMP_NAME-$TIMESTAMP.tgz $DUMP_DIR/$DUMP_NAME
if [ -f $DUMP_DIR/$DUMP_NAME-$TIMESTAMP.tgz ]; then
	log "Archive was created"
	else
	log "Archivation end with error, no archive was foumd"
	fi
docker exec -it mongodb rm -rf /dump
log "Temp docker dir \"$DUMP_DIR\" removed"
rm -rf $DUMP_DIR/$DUMP_NAME
log "Temp dir \"$DUMP_DIR/$DUMP_NAME\" removed"
log "All done! Logs in \"$LOGDIR\"" && exit


