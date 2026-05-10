#!/bin/bash

LIST="config/docs.list"

mkdir -p archives

while read NAME URL
do

# ignore empty lines
[ -z "$NAME" ] && continue

# ignore comments
[[ "$NAME" =~ ^# ]] && continue

echo "Fetching $NAME -> $URL"

wget \
--mirror \
--timestamping \
--convert-links \
--adjust-extension \
--page-requisites \
--no-parent \
--wait=1 \
--random-wait \
--limit-rate=500k \
--directory-prefix archives/$NAME \
$URL

done < $LIST
