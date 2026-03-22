#!/bin/bash

# Your exact SSH alias and target directory
TARGET="track-reporting-contabo:/home/rc-tech/mobasir/backend/"

echo "Performing initial push to Ubuntu..."
# -a (archive/preserve permissions), -z (compress), --delete (remove files on server if you delete them locally)
rsync -az --exclude '.git' --exclude 'bin' --delete ./ $TARGET

echo "Watching for local changes..."
# inotifywait watches the folder. When you save a file, it triggers the rsync push
while inotifywait -r -q -e modify,create,delete,move --exclude '\.git' ./; do
    echo "Syncing changes to server..."
    rsync -az --exclude '.git' --exclude 'bin' --delete ./ $TARGET
done
