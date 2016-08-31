#!/bin/sh
#Include folders
APP_NAME="chme"	#(Your METEOR_APP name used for sorting logs)
MONGODB_NAME="name of your db on mongo" #(Your mongo dbname created for your app)
DOCKER_DUMP_DIR=/my/dump/dir #(dir which creates when you\'re using commang \'docker ... mongorestore\')
TIMESTAMP=`date +%F-%H%M` 
LOG_NAME="$APP_NAME-$TIMESTAMP"
LOGDIR=/my/log/dir	#(dir which used for save script logs, can be different)
MONGO_DUMP_DIR=$DOCKER_DUMP_DIR/mongodump	#(may be different, temp dir which creades at start script and removes at end)
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
	rm -rf $MONGO_DUMP_DIR
	mkdir $MONGO_DUMP_DIR
	log "\"$MONGO_DUMP_DIR\" folder renew"
	else
	log "No such \"$MONGO_DUMP_DIR\" folder was found"
	mkdir $MONGO_DUMP_DIR
	log "\"$MONGO_DUMP_DIR\" folder was created"
	fi
	}
	syncmongo(){
if [ -d $MONGO_DUMP_DIR ];
	then
	log "Check mongo dump folder pass!"
	log "Synchronize mongo_dump from Amazon S3"
	s3cmd --acl-private --bucket-location=EU --guess-mime-type sync $AMAZON_DIR/ $MONGO_DUMP_DIR/$MONGODB_NAME
	log "mongo_dump restored from Amazon S3"
fi
}
	#do the docker dump and copy it to dump folder
checklogdir
checkdir
syncmongo

if [ -d $MONGO_DUMP_DIR/$MONGODB_NAME ]; then
	docker cp $MONGO_DUMP_DIR/ mongodb:$DOCKER_DUMP_DIR/
	log "Mongo dump copyed to docker mongo dump dir \"$DOCKER_DUMP_DIR\""
	else
	log "Error folder not copyed, check original folder for exist"
	fi
log "Start mongorestore"
docker exec -it mongodb mongorestore --drop
log "restored"
rm -rf $MONGO_DUMP_DIR/$MONGODB_NAME
docker exec -it mongodb rm -rf /dump
log "Temporary mongo dump dirs removed"
log "All done! Logs in \"$LOGDIR\"" && exit


