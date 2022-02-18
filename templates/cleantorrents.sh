#!/bin/sh
# Automatically remove a torrent and delete its data after a specified period of time
# Written to work with the enviroment variables of the Haugene transmission docker container
#===USER VARIABLES===
#Seconds that torrents seed for [5184000 = 60 days] [864000 = 10 days] [43200 = 12 hours]
SEED_CUTOFF=5184000
#Choose between "--remove" or "--remove-and-delete"
REMOVAL_COMMAND="--remove"
#
#===SCRIPT===
if [[ "${TORRENT_SEEDTIME}" == "" ]]; then TORRENT_SEEDTIME=0; fi
if ! ( [[ "${REMOVAL_COMMAND}" == "--remove" ]] || [[ "${REMOVAL_COMMAND}" == "--remove-and-delete" ]] ); then exit 2; fi
#Build connection string
TRANSMISSION_COMMAND="/usr/bin/transmission-remote localhost:${TRANSMISSION_RPC_PORT} --auth ${TRANSMISSION_RPC_USERNAME}:${TRANSMISSION_RPC_PASSWORD}"
TORRENT_ID_LIST=`$TRANSMISSION_COMMAND -l | sed -e '1d' -e '$d' | awk '{print $1}' | sed -e 's/[^0-9]*//g'`
# Show output header
printf '%-3.3s %-50.50s  %-8.8s  %-6.6s  %s \n' "ID" "NAME" "SEEDTIME" "ACTION" "RESULT"
# Write to docker log
NOW=$(date)
printf '%s Running torrent cleanup script with cutoff: %ds \n' "$NOW" $SEED_CUTOFF >/proc/1/fd/1
# Parse all torrents in client
for TORRENT_ID in $TORRENT_ID_LIST; do
    # Get Torrent name and seeding time in seconds
    TORRENT_NAME=`$TRANSMISSION_COMMAND --torrent $TORRENT_ID --info | grep "Name:" | sed 's/.*Name: \(.*\)/\1/'`
    TORRENT_SEEDTIME=`$TRANSMISSION_COMMAND --torrent $TORRENT_ID --info | grep "Seeding Time" | sed 's/.*(\(.*\) seconds)/\1/'`
    # Set seedtime to Zero if incomplete
    if [[ "${TORRENT_SEEDTIME}" == "" ]]; then TORRENT_SEEDTIME=0; fi
    # Compare torrent seedtime to cutoff
    if [ $TORRENT_SEEDTIME -gt $SEED_CUTOFF ]; then TORRENT_ACTION="remove"; else TORRENT_ACTION="keep"; fi
    # Perform Action
    ACTION_RESULT="(no action taken)"
    if [[ "${TORRENT_ACTION}" == "remove" ]]; then
        # Remove torrent (does not delete data)
        ACTION_RESULT=`$TRANSMISSION_COMMAND --torrent $TORRENT_ID $REMOVAL_COMMAND | sed 's/^.\{33\}//'`
        # Write entry in docker log
        printf 'Removed %s (seed time: %ds) [%s] \n' "${TORRENT_NAME}" $TORRENT_SEEDTIME "${ACTION_RESULT}" >/proc/1/fd/1
    fi
    # Show item status
    printf '%-3d %-50.50s  %7ds  %-6.6s  %s \n' $TORRENT_ID "${TORRENT_NAME}"  $TORRENT_SEEDTIME "${TORRENT_ACTION}" "${ACTION_RESULT}"
done
