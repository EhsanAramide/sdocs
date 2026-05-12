#!/bin/bash
set -u

LIST="config/docs.list"
MAX_SIZE_MB=500
DOWNLOAD_LEVEL=2

mkdir -p archives

while read -r NAME URL; do
    [[ -z "$NAME" || "$NAME" == \#* ]] && continue

    DOMAIN=$(echo "$URL" | awk -F/ '{print $3}')
    echo "Fetching $NAME ($URL)"

    mkdir -p "archives/$NAME"

    wget \
        --recursive \
        --level="$DOWNLOAD_LEVEL" \
        --no-parent \
        --domains="$DOMAIN" \
        --quota="${MAX_SIZE_MB}m" \
        --timestamping \
        --convert-links \
        --adjust-extension \
        --page-requisites \
        --wait=1 \
        --random-wait \
        --limit-rate=500k \
        --timeout=15 \
        --read-timeout=30 \
        --tries=3 \
        --reject "mp4,zip,tar,exe,dmg,iso,pdf,psd,jpg,png,gif,avi,mov,mp3,ogg,wav,woff,woff2" \
        --directory-prefix="archives/$NAME" \
        "$URL"

    if [ $? -ne 0 ]; then
        echo "wget failed for $NAME. Continuing..."
    fi
done < "$LIST"
