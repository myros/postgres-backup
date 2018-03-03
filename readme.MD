
# Automated Docker PostgreSQL Backup

This Docker image runs pg_dump to backup one or multiple databases using cron job to folder `/backups` and notifies Slack.

If SLACK vars are set, SLACK channel will be notified.

## Features

* Backup multiple Postgres databases
* Slack notification
* Automatic, scheduled backups
* Nice documentation and samples
* Docker-compose file included

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

Variable | Description
--- | ---
PG_HOST | the host/ip of your postgres database
PG_PORT | the port number of your postgres database
PG_USER | the username of your postgres database
PG_PASSWORD | the password of your postgres database
PG_DB | the database name(s) to dump. If you want to use multiple databases, delimit with ";"

### Optional variables

Variable | Description
--- | ---
PG_EXTRA_OPTS | the extra options to pass to pg_dump command
SCHEDULE | the interval of cron job to run pg_dump. `@daily` by default, which is every day at 00:00.

### Slack variables (optional)

Variable | Description
--- | ---
SLACK_CHANNEL | Slack channel
SLACK_HOST | Slack webhook
SLACK_MESSAGE | Message that will be posted. Default message: `Database backup done (2018.03.03) (database1; database2...)`

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

networks:
  default:
    external:
      name: NAME_OF_YOUR_POSTGRES_NETWORK
```

## One time backup examples

#### Just backup

```
  docker run -e PG_HOST=postgres \
    -e PG_DB=database_name \
    -e PG_USER=docker \
    -e PG_PASSWORD=docker \
    -e PG_PORT=5432 \
    myros/postgres-backup /backup.sh
```

#### With network

```
  docker run -e PG_HOST=postgres \
    -e PG_DB=database_name \
    -e PG_USER=docker \
    -e PG_PASSWORD=docker \
    -e PG_PORT=5432 \
    --network YOUR_PG_NETWORK \
    myros/postgres-backup /backup.sh
```

#### With network and Slack

```
  docker run -e PG_HOST=postgres \
    -e PG_DB=database_name \
    -e PG_USER=docker \
    -e PG_PASSWORD=docker \
    -e PG_PORT=5432 \
    -e SLACK_HOST=SLACK_WEBHOOK_URL \
    -e SLACK_CHANNEL=backups --network YOUR_PG_NETWORK \
    myros/postgres-backup /backup.sh
```

## Restore from a backup

To see the list of backups, you can run:

    docker exec docker-postgres-backup ls /backups

To restore database from a certain backup, simply run:


```
    docker run docker run -e PG_HOST=postgres -e PG_DB=dbname -e PG_USER=user -e PG_PASSWORD=password  myros/docker-postgres-backup /restore.sh /backups/PATH_TO_YOUR_FILE
```

## TODO

* S3 upload/download
* sending emails
* proper restore & import
