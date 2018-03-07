#!/bin/bash

set -e

post_to_slack() {
  # format message as a code block ```${msg}```
  SLACK_MESSAGE="\`\`\`$1\`\`\`"
  SLACK_URL=$SLACK_HOST

  case "$2" in
    INFO)
      SLACK_ICON=':slack:'
      ;;
    WARNING)
      SLACK_ICON=':warning:'
      ;;
    ERROR)
      SLACK_ICON=':bangbang:'
      ;;
    *)
      SLACK_ICON=':slack:'
      ;;
  esac

  curl -s -d "payload={\"text\": \"${SLACK_ICON} ${SLACK_MESSAGE}\"}" ${SLACK_URL}
}


if [ -z "${PG_HOST}" ]; then
  echo "You need to set the PG_HOST environment variable."
  exit 1
fi

if [ -z "${PG_DB}" ]; then
  echo "You need to set the PG_DB environment variable."
  exit 1
fi

if [ -z "${PG_USER}" ]; then
  echo "You need to set the PG_USER environment variable."
  exit 1
fi

if [ -z "${PG_PASSWORD}" ]; then
  echo "You need to set the PG_PASSWORD environment variable."
  exit 1
fi

if [ -z "${PG_PORT}" ]; then
  echo "You need to set the PG_PORT environment variable."
  exit 1
fi

# fi

# # CHECK S3 UPLOAD
# if [ -z "$S3_ACCESS_KEY" -o -z "$S3_SECRET_KEY" -o -z "$S3_BUCKET" ]; then
#   # no AWS data, no S3 upload
#
# fi

#Proces vars
export PGPASSWORD=$PG_PASSWORD
POSTGRES_HOST_OPTS="-h $PG_HOST -p $PG_PORT -U $PG_USER $PG_EXTRA_OPTS"

#Initialize filename vers and dirs
BACKUP_DIR="/backups"

YEAR=`date +%Y`
MONTH=`date +%m`
DAY=`date +%d`
BACKUP_PATH="$BACKUP_DIR/$YEAR/$MONTH/$DAY"
mkdir -p $BACKUP_PATH

# getting database list
DBS=$(echo $PG_DB | tr ";" "\n")

declare -a DB_DONE

for db in $DBS; do
  #Create dump
  echo "Creating dump of ${db} database from ${PG_HOST}..."
  FILE_NAME=${db}-`date +%H%M%S`.sql.gz
  echo "pg_dump $POSTGRES_HOST_OPTS $db > $BACKUP_PATH/$FILE_NAME"
  pg_dump $POSTGRES_HOST_OPTS $db > $BACKUP_PATH/$FILE_NAME
  DB_DONE+="$db; "
done

# post slack message
if [ ! -z $SLACK_HOST ] && [ ! -z $SLACK_CHANNEL ]; then
  echo "Notifying slack..."
  CURRENT_DATE=`date +%Y.%m.%d`
  CURRENT_TIME=`date +%H:%M`
  SLACK="$SLACK\n${DB_DONE}"
  SLACK="$SLACK\nPostgres Database backup done at ($CURRENT_TIME)"
  MESSAGE=${SLACK_MESSAGE:-$SLACK}
  echo $MESSAGE
  post_to_slack "$MESSAGE" "INFO"
fi


echo "SQL backup uploaded successfully"
