
# Docker PostgreSQL Backup

This image runs pg_dump to backup one or multiple databases using cron job to folder `/backups`

If SLACK vars are set, SLACK channel will be notified.

## Usage:

    docker run -d \
        --env PG_HOST=postgres \
        --env PG_PORT=5432 \
        --env PG_USER=docker \
        --env PG_PASSWORD=docker \
        --volume /host_folder:/backups
        myros/postgres-backup

## Periodic backups

You can change the SCHEDULE environment variable like -e SCHEDULE="@daily" or SCHEDULE="@every 6h" to change its default frequency, by default is daily.

More information about the scheduling can be found [here](https://godoc.org/github.com/robfig/cron#hdr-Predefined_schedules).

## Required variables

  PG_HOST      the host/ip of your postgres database
  PG_PORT      the port number of your postgres database
  PG_USER      the username of your postgres database
  PG_PASSWORD      the password of your postgres database
  PG_DB        the database name to dump. Default: `--all-databases`
  EXTRA_OPTS      the extra options to pass to pg_dump command
  SCHEDULE       the interval of cron job to run pg_dump. `@daily` by default, which is every day at 00:00. More information on cron.
  MAX_BACKUPS     the number of backups to keep. When reaching the limit, the old backup will be discarded. No limit by default
  INIT_BACKUP     if set, create a backup when the container starts
  INIT_RESTORE_LATEST if set, restores latest backup
  SCHEDULE=@every 1m


## Docker compose

```
version: "2"

services:
  pgbackups:
    image: postgres-backup
    volumes:
      - ~/backups/pg:/backups
    environment:
      PG_HOST: postgres
      PG_PORT: 5432
      PG_USER: docker
      PG_PASSWORD: docker
      PG_DB: database1; database2; database3
      PG_EXTRA_OPTS: "-w -Fc"
      SCHEDULE: "@daily"
      SLACK_CHANNEL: "channel"
      SLACK_HOST: "https://hooks.slack.com/services/YOUR_DATA"
      SLACK_MESSAGE: "Database backup done"

networks:
  default:
    external:
      name: NAME_OF_YOUR_POSTGRES_NETWORK
```

## One time backup

```
docker run docker run -e PG_HOST=postgres -e PG_DB=dbname -e PG_USER=user -e PG_PASSWORD=password  myros/docker-postgres-backup sh backup.sh
```

## Restore from a backup

To see the list of backups, you can run:

    docker exec docker-postgres-backup ls /backup

To restore database from a certain backup, simply run:


```
    docker run docker run -e PG_HOST=postgres -e PG_DB=dbname -e PG_USER=user -e PG_PASSWORD=password  myros/docker-postgres-backup /restore.sh /backups/PATH_TO_YOUR_FILE
```
