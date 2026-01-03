## Nextcloud with Redis and MariaDB
This example defines one of the basic setups for Nextcloud. More details on how to
further customize the installation and the compose file can be found on the
[official image page](https://hub.docker.com/_/nextcloud).

Project structure:
```
.
├── compose.yaml
└── README.md
```

[_compose.yaml_](compose.yaml)
```
services:
  nc:
    image: nextcloud:apache
    ports:
      - 8888:80
    ...
  redis:
    image: redis:alpine
    restart: always
    networks:
      - redisnet
  db:
    image: mariadb
    ...
```

When deploying this setup, docker compose maps the nextcloud container port 8888 to
port 80 of the host as specified in the compose file.

## Deploy with docker compose

```
$ docker compose up -d
Creating network "nextcloud-redis-mariadb_redisnet" with the default driver
Creating network "nextcloud-redis-mariadb_dbnet" with the default driver
Creating volume "nextcloud-redis-mariadb_nc_data" with default driver
Pulling redis (redis:alpine)...
alpine: Pulling from library/redis....
....
Status: Downloaded newer image for mariadb:latest
Creating nextcloud-redis-mariadb_db_1    ... done
Creating nextcloud-redis-mariadb_nc_1    ... done
Creating nextcloud-redis-mariadb_redis_1 ... done
```


## Expected result

Check containers are running and the port mapping:
```
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
6541add4d648        nextcloud:apache    "/entrypoint.sh apac…"   35 seconds ago      Up 34 seconds       0.0.0.0:8888->80/tcp   nextcloud-redis-mariadb_nc_1
6c656f98cf14        redis:alpine        "docker-entrypoint.s…"   35 seconds ago      Up 34 seconds       6379/tcp             nextcloud-redis-mariadb_redis_1
6d4c6630a4a3        mariadb             "docker-entrypoint.s…"   35 seconds ago      Up 34 seconds       3306/tcp             nextcloud-redis-mariadb_db_1
```

Navigate to `http://localhost:8888` in your web browser to access the installed
Nextcloud service.

![page](output.jpg)

Stop and remove the containers

```
$ docker compose down
```

To delete all data, remove all named volumes by passing the `-v` arguments:
```
$ docker compose down -v
```

## Deploy Nextcloud with bootstraped data

If you don't want to set the initial configuration of Next Cloud each time you start the containers from scratch, you could use the `compose-bootstrapped.yaml` file included. This yaml is set to:

* Set the admin user so you once the container starts you could inmediately access the application using the credentials:
   * User: admin
   * Password: secret

* Create a sidecar container that is temporary loaded along with the rest of the containers, the sidecar uses the CLI of nextcloud to load the following data:
   * A new QA user (qauser / qasecretpass)
   * A new testing group (and assign the QA user to it)
   * A new text file.

NOTE: At the moment the sidecar is not loading the data, this need to be fixed.

The command to use it is:
```
$ docker compose -f compose-bootstraped.yaml up -d
```

## Cleaning all

WARNING: These commands will destroy the elements according to the command. This is to be used when we want a fresh environment.

### Cleaning by specific elements:

You can clean data and start fresh by running in the console:

```
docker-compose down
docker container prune -a -f
docker volume prune -a -f
```

Other usefull cleaning commands

```
docker container prune -a -f
docker image prune -a -f
```

### Cleaning all at once:

Warning: Use carefully since running this will stop/delete containers, delete images, delete volumes, delete networks.

```
docker compose down
docker system prune -a -f
```