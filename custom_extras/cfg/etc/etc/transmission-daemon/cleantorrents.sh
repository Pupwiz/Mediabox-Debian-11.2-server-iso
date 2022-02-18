
#!/bin/bash

#
# INFO
#

# This works if sonarr and radarr are set up to have a Category of sonarr and radarr respectively 
# If you are using other Categories to save your automated downloads, update the script where you see:
#    "movies"|"series"|"music"|"general")
# This script will not touch anything outside those Categories

# Set this file on a cron for every 5 minutes
# Using Docker? Make your cron something like this:
#   /usr/bin/docker exec $(/usr/bin/docker ps | grep "linuxserver/transmission:latest" | awk '{print $1}') bash "/path/to/transmission-gc.sh"

# Set =~ to be insensitive
shopt -s nocasematch

TRANS_REMOTE_BIN=/usr/bin/transmission-remote
TRANS_HOST="127.0.0.1:9091"
TRANS_AUTH="admin:password"

# Amount of time (in seconds) after a torrent completes to delete them
DAYS=4
RETENTION=$((DAYS * 24 * 60 * 60))

# Delete torrents only when ratio is above
RATIO="1.0"

# Clean up torrents where trackers have torrent not registered
# filter list by * (which signifies a tracker error)
TORRENT_DEAD_LIST=($("${TRANS_REMOTE_BIN}" "${TRANS_HOST}" --auth "${TRANS_AUTH}" -l | sed -e '1d;$d;s/^ *//' | cut -s -d ' ' -f 1 | grep -E '[0-9]+\*' | sed 's/\*$//'))
for torrent_id in "${TORRENT_DEAD_LIST[@]}"
do
  # Get the torrents metadata
  torrent_info=$("${TRANS_REMOTE_BIN}" "${TRANS_HOST}" --auth "${TRANS_AUTH}" --torrent "${torrent_id}" -i -it)
  torrent_name=$(echo "${torrent_info}" | grep "Name: *" | sed 's/Name\:\s//i' | awk '{$1=$1};1')
  torrent_path=$(echo "${torrent_info}" | grep "Location: *" | sed 's/Location\:\s//i' | awk '{$1=$1};1')
  # torrent_size=$(echo "${torrent_info}" | grep "Downloaded: *" | sed 's/Downloaded\:\s//i' | awk '{$1=$1};1')
  torrent_label=$(basename "${torrent_path}")

  case "${torrent_label}" in
    "movies"|"series"|"music"|"general"|"books")
      torrent_error=$(echo "${torrent_info}" | grep "Got an error" | cut -d \" -f2)
      if [[ "${torrent_error}" =~ "unregistered" ]] || [[ "${torrent_error}" =~ "not registered" ]]; then
        # Delete torrent
        "${TRANS_REMOTE_BIN}" "${TRANS_HOST}" --auth "${TRANS_AUTH}" --torrent "${torrent_id}" --remove-and-delete > /dev/null
      fi
  esac
done

# Clean up torrent where ratio is > ${RATIO} or seeding time > ${RETENTION} seconds
# do not filter the list, get all the torrents
TORRENT_ALL_LIST=($("${TRANS_REMOTE_BIN}" "${TRANS_HOST}" --auth "${TRANS_AUTH}" -l | sed -e '1d;$d;s/^ *//' | cut -s -d ' ' -f 1))
for torrent_id in "${TORRENT_ALL_LIST[@]}"
do
  # Get the torrents metadata
  torrent_info=$("${TRANS_REMOTE_BIN}" "${TRANS_HOST}" --auth "${TRANS_AUTH}" --torrent "${torrent_id}" -i -it)
  torrent_name=$(echo "${torrent_info}" | grep "Name: *" | sed 's/Name\:\s//i' | awk '{$1=$1};1')
  torrent_path=$(echo "${torrent_info}" | grep "Location: *" | sed 's/Location\:\s//i' | awk '{$1=$1};1')
  # torrent_size=$(echo "${torrent_info}" | grep "Downloaded: *" | sed 's/Downloaded\:\s//i' | awk '{$1=$1};1')
  torrent_label=$(basename "${torrent_path}")
  # torrent_datefinished_seconds=$(echo "${torrent_info}" | grep "Date finished: *" | awk 'BEGIN{months="  JanFebMarAprMayJunJulAugSepOctNovDec"}{print $7"."index(months,$4)/3"."$5"-"$6}' | awk '{$1=$1};1')
  torrent_datefinished_seconds=$(echo "${torrent_info}" | grep "Date finished: *" | sed 's/Date finished\: \s//i' | awk '{$1=$1};1')
  torrent_ratio=$(echo "${torrent_info}" | grep "Ratio: *" | sed 's/Ratio\:\s//i' | awk '{$1=$1};1')
  
  date_in_seconds=$(date +%s)
  
  if [[ "${torrent_datefinished_seconds}" == "" ]]; then
    datefinished_in_seconds=$date_in_seconds                            # Still downloading
  else
    datefinished_in_seconds=$(date -d "$torrent_datefinished_seconds" +%s) # Download finished
  fi
  
  torrent_seeding_seconds=$((date_in_seconds - datefinished_in_seconds))
  torrent_seeding_days=$((torrent_seeding_seconds / 60 / 60 / 24))

  # Debug
  echo "${torrent_id} - ${torrent_ratio} - ${torrent_seeding_seconds} secs - ${torrent_seeding_days}/$DAYS days - ${torrent_label} - ${torrent_name}"

  case "${torrent_label}" in
    "movies"|"series"|"music"|"general"|"books")
      # Torrents without a ratio have "None" instead of "0.0" let's fix that
      if [[ "${torrent_ratio}" =~ "None" ]]; then
        torrent_ratio="0.0"
      fi

      # delete torrents greater than ${TTL_SECONDS}
      if [[ "${torrent_seeding_seconds}" -gt "${RETENTION}" ]]; then
        "${TRANS_REMOTE_BIN}" "${TRANS_HOST}" --auth "${TRANS_AUTH}" --torrent "${torrent_id}" --remove-and-delete > /dev/null
      fi

      # delete torrents greater than ${RATIO}
      if (( $(echo "${torrent_ratio} ${RATIO}" | awk '{print ($1 > $2)}') )); then
        "${TRANS_REMOTE_BIN}" "${TRANS_HOST}" --auth "${TRANS_AUTH}" --torrent "${torrent_id}" --remove-and-delete > /dev/null
      fi
      ;;
  esac  
done
