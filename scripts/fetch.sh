#!/usr/bin/env bash

set -uo pipefail

LIST="config/docs.list"
CONFIG_DIR="config/sites"

DEFAULT_LEVEL=5
DEFAULT_MAX_SIZE_MB=500
DEFAULT_WAIT=1
DEFAULT_RATE="500k"

DEFAULT_REJECT="mp4,zip,tar,exe,dmg,iso,pdf,psd,avi,mov,mp3,ogg,wav"

DEFAULT_REJECT_REGEX="(_sources|_downloads)"

mkdir -p archives

while read -r NAME URL; do
    [[ -z "${NAME:-}" || "$NAME" == \#* ]] && continue

    DOMAIN=$(printf '%s\n' "$URL" | sed -E 's#https?://([^/]+)/?.*#\1#')

    LEVEL="$DEFAULT_LEVEL"
    MAX_SIZE_MB="$DEFAULT_MAX_SIZE_MB"
    WAIT="$DEFAULT_WAIT"
    RATE="$DEFAULT_RATE"
    REJECT="$DEFAULT_REJECT"
    REJECT_REGEX="$DEFAULT_REJECT_REGEX"

    CONF="$CONFIG_DIR/$NAME.conf"

    if [[ -f "$CONF" ]]; then
        source "$CONF"
    fi

    echo
    echo "================================="
    echo "Fetching: $NAME"
    echo "URL: $URL"
    echo "Domain: $DOMAIN"
    echo "Level: $LEVEL"
    echo "Quota: ${MAX_SIZE_MB}MB"
    echo "================================="

    mkdir -p "archives/$NAME"

    wget \
        --recursive \
        --level="$LEVEL" \
        --no-parent \
        --domains="$DOMAIN" \
        --quota="${MAX_SIZE_MB}m" \
        --timestamping \
        --convert-links \
        --adjust-extension \
        --page-requisites \
        --compression=auto \
        --wait="$WAIT" \
        --random-wait \
        --limit-rate="$RATE" \
        --timeout=15 \
        --read-timeout=30 \
        --tries=3 \
        --reject="$REJECT" \
        --reject-regex="$REJECT_REGEX" \
        --directory-prefix="archives/$NAME" \
        "$URL"

    STATUS=$?

    if [[ $STATUS -ne 0 ]]; then
        echo "wget failed for $NAME (exit=$STATUS)"
        continue
    fi

    echo "Done: $NAME"

done < "$LIST"
