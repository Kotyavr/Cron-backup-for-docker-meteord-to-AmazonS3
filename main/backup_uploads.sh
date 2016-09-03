#!/bin/bash
APP_NAME="chme"	#(Your METEOR_APP name used for sorting logs)
IMG_DIR_NAME="nameyourimagedir" #(name of dir where storaged your images for yours app, use only name wiithout path, for path use APP_DIR below)
TIMESTAMP=`date +%F-%H%M`
LOG_NAME="$APP_NAME-$TIMESTAMP"
IMAGES_DUMP_DIR=/dump/images	#(cooperate with 'IMAGES_DUMP_DIR' in backup_dump.sh)
APP_DIR=/your/app/deploing/folder/	#(Your METEOR_APP deploy dir)
LOGDIR=/my/log/dir	#(dir which used for save script logs, can be different)
AMAZON_DIR=s3://mybucketname/uploadsrestore	#(cooperate with your Amazon S3 dtorage bucket)

checklogdir(){ if [ -d $LOGDIR ]; then
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
 checkdir(){ if [ -d $IMAGES_DUMP_DIR ]; then
	log "Images dump folder exist"
	else
	log "No such \"images\" dump folder was found"
	mkdir $IMAGES_DUMP_DIR
	log "Folder \"$IMAGES_DUMP_DIR\" was created"
	fi
}
checklogdir
checkdir
cp -r $APP_DIR/$IMG_DIR_NAME/ $IMAGES_DUMP_DIR/$IMG_DIR_NAME/
if [ -d $IMAGES_DUMP_DIR/$IMG_DIR_NAME/ ]; then
	log "Origilan img folder copyed to temp dir \"$IMAGES_DUMP_DIR/$IMG_DIR_NAME\""
	else
	log "Error folder not copyed, chexk original folder for exist or privileges"
	fi
	tar -zcvf $IMAGES_DUMP_DIR/$IMG_DIR_NAME-$TIMESTAMP.tgz $IMAGES_DUMP_DIR/$IMG_DIR_NAME
	if [ -f $IMAGES_DUMP_DIR/$IMG_DIR_NAME-$TIMESTAMP.tgz ]; then
	log "Archive was created"
	else
	log "Archivation end with error, no archive was foumd"
	fi
rm -rf $IMAGES_DUMP_DIR/$IMG_DIR_NAME log "Folder \"$IMAGES_DUMP_DIR/$IMG_DIR_NAME\" removed"
log "All done! Logs in $LOGDIR" && exit
