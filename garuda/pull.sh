#!/bin/bash

TARGET="track-reporting-contabo:/home/rc-tech/mobasir/backend/"

echo "Pulling generated files from Ubuntu..."
# Notice the target and destination are swapped.
# We do NOT use --delete here, to protect your local uncommitted work.
rsync -az --exclude '.git' --exclude 'bin' $TARGET ./
echo "Pull complete!"
