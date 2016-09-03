#!/bin/bash
APP_NAME="spectre-images"
APP_FOLD=".uploads"
TIMESTAMP=`date +%F-%H%M`
DUMP_DIR=/dump/images
LOGDIR=/dumplog
BACKUPS_DIR=/opt/spectre/current/bundle
BACKUP_NAME="$APP_NAME-$TIMESTAMP"
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
   echo $message >>$LOGDIR/$BACKUP_NAME
   }
 checkdir(){ if [ -d $DUMP_DIR ]; then
	log "Images dump folder exist"
	else
	log "No such \"images\" dump folder was found"
	mkdir $DUMP_DIR
	log "Folder \"$DUMP_DIR\" was created"
	fi
}
checklogdir
checkdir
cp -r $BACKUPS_DIR/.uploads/ $DUMP_DIR/.uploads/
if [ -d $DUMP_DIR/.uploads/ ]; then
	log "Origilan img folder copyed to temp dir \"$DUMP_DIR/$BACKUP_NAME\""
	else
	log "Error folder not copyed, chexk original folder for exist or privileges"
	fi
	tar -zcvf $DUMP_DIR/uploads-$TIMESTAMP.tgz $DUMP_DIR/$APP_FOLD
	if [ -f $DUMP_DIR/uploads-$TIMESTAMP.tgz ]; then
	log "Archive was created"
	else
	log "Archivation end with error, no archive was foumd"
	fi
rm -rf $DUMP_DIR/$APP_FOLD log "Folder \"$DUMP_DIR/$BACKUP_NAME\" removed"
log "All done! Logs in $LOGDIR" && exit
