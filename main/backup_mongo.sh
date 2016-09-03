#!/bin/sh
#Include folders
APP_NAME="chme"	#(Your METEOR_APP name used for sorting logs)
MONGODB_NAME="name of your db on mongo"	#(Your mongo dbname created for your app)
DOCKER_DUMP_DIR=/my/dump/dir	#(dir which creates when you\'re using commang \'docker ... mongodump\')
TIMESTAMP=`date +%F-%H%M` 
LOG_NAME="$APP_NAME-$TIMESTAMP"
LOGDIR=/my/log/dir	#(dir which used for save script logs, can be different)
MONGO_DUMP_DIR=$DOCKER_DUMP_DIR/mongo #(cooperate with 'MONGO_DUMP_DIR' in backup_dump.sh)
AMAZON_DIR=s3://mybucketname/mongorestore	#(cooperate with your Amazon S3 dtorage bucket)

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
   #check the dump folder, create if not exist
   checkdir(){
if [ -d $MONGO_DUMP_DIR ];
	then
	log "\"$MONGO_DUMP_DIR\" folder exist"
	else
	log "No such \"dump\" folder was found"
	mkdir $MONGO_DUMP_DIR
	log "\"$MONGO_DUMP_DIR\" folder was created"
	fi
	}
	#do the docker dump and copy it to dump folder
checklogdir
checkdir
log "Start mongodump"
docker exec -it mongodb mongodump
log "Mongo dumped"
docker cp mongodb:$DOCKER_DUMP_DIR/$MONGODB_NAME/ $MONGO_DUMP_DIR/$MONGODB_NAME/
if [ -d $MONGO_DUMP_DIR/$MONGODB_NAME ]; then
	log "Mongo dump copyed to temp dir \"$MONGO_DUMP_DIR/$MONGODB_NAME\""
	else
	log "Error folder not copyed, check original folder for exist"
	fi
#archive mongo dump
tar -zcvf $MONGO_DUMP_DIR/$MONGODB_NAME-$TIMESTAMP.tgz $MONGO_DUMP_DIR/$MONGODB_NAME
if [ -f $MONGO_DUMP_DIR/$MONGODB_NAME-$TIMESTAMP.tgz ]; then
	log "Archive was created"
	else
	log "Archivation end with error, no archive was foumd"
	fi
docker exec -it mongodb rm -rf /dump
log "Temp docker dir \"$DOCKER_DUMP_DIR\" removed"
rm -rf $MONGO_DUMP_DIR/$DUMP_NAME
log "Temp dir \"$MONGO_DUMP_DIR/$DUMP_NAME\" removed"
log "All done! Logs in \"$LOGDIR\"" && exit


