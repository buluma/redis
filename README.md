# Redis

[![redis, 6.0-bullseye](https://github.com/buluma/redis/actions/workflows/6.0-bullseye.yml/badge.svg?branch=main)](https://github.com/buluma/redis/actions/workflows/6.0-bullseye.yml) [![redis, 6.2 bullseye](https://github.com/buluma/redis/actions/workflows/bullseye.yml/badge.svg?branch=main)](https://github.com/buluma/redis/actions/workflows/bullseye.yml)

Redis is an open source key-value store that functions as a data structure server.

## Quick reference

    Maintained by: the Docker Community

    Where to get help: the Docker Community Forums, the Docker Community Slack, or Stack Overflow

## Supported tags and respective Dockerfile links

    6.2.6, 6.2, 6, latest, 6.2.6-bullseye, 6.2-bullseye, 6-bullseye, bullseye
    6.2.6-alpine, 6.2-alpine, 6-alpine, alpine, 6.2.6-alpine3.15, 6.2-alpine3.15, 6-alpine3.15, alpine3.15
    6.0.16, 6.0, 6.0.16-bullseye, 6.0-bullseye
    6.0.16-alpine, 6.0-alpine, 6.0.16-alpine3.15, 6.0-alpine3.15
    5.0.14, 5.0, 5, 5.0.14-bullseye, 5.0-bullseye, 5-bullseye
    5.0.14-32bit, 5.0-32bit, 5-32bit, 5.0.14-32bit-bullseye, 5.0-32bit-bullseye, 5-32bit-bullseye
    5.0.14-alpine, 5.0-alpine, 5-alpine, 5.0.14-alpine3.15, 5.0-alpine3.15, 5-alpine3.15

## Quick reference (cont.)

    Where to file issues: https://github.com/docker-library/redis/issues

    Supported architectures: (more info) amd64, arm32v5, arm32v6, arm32v7, arm64v8, i386, mips64le, ppc64le, s390x

    Published image artifact details: repo-info repo's repos/redis/ directory (history) (image metadata, transfer size, etc)

    Image updates: official-images repo's library/redis label
    official-images repo's library/redis file (history)

    Source of this description: docs repo's redis/ directory (history)

## What is Redis?

Redis is an open-source, networked, in-memory, key-value data store with optional durability. It is written in ANSI C. The development of Redis is sponsored by Redis Labs today; before that, it was sponsored by Pivotal and VMware. According to the monthly ranking by DB-Engines.com, Redis is the most popular key-value store. The name Redis means REmote DIctionary Server.

    wikipedia.org/wiki/Redis

## Security

For the ease of accessing Redis from other containers via Docker networking, the "Protected mode" is turned off by default. This means that if you expose the port outside of your host (e.g., via -p on docker run), it will be open without a password to anyone. It is highly recommended to set a password (by supplying a config file) if you plan on exposing your Redis instance to the internet. For further information, see the following links about Redis security:

    Redis documentation on security
    Protected mode
    A few things about Redis security by antirez

## How to use this image
start a redis instance

$ docker run --name some-redis -d redis

start with persistent storage

$ docker run --name some-redis -d redis redis-server --save 60 1 --loglevel warning

There are several different persistence strategies to choose from. This one will save a snapshot of the DB every 60 seconds if at least 1 write operation was performed (it will also lead to more logs, so the loglevel option may be desirable). If persistence is enabled, data is stored in the VOLUME /data, which can be used with --volumes-from some-volume-container or -v /docker/host/dir:/data (see docs.docker volumes).

For more about Redis Persistence, see http://redis.io/topics/persistence.
connecting via redis-cli

$ docker run -it --network some-network --rm redis redis-cli -h some-redis

Additionally, If you want to use your own redis.conf ...

You can create your own Dockerfile that adds a redis.conf from the context into /data/, like so.

FROM redis
COPY redis.conf /usr/local/etc/redis/redis.conf
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]

Alternatively, you can specify something along the same lines with docker run options.

$ docker run -v /myredis/conf:/usr/local/etc/redis --name myredis redis redis-server /usr/local/etc/redis/redis.conf

Where /myredis/conf/ is a local directory containing your redis.conf file. Using this method means that there is no need for you to have a Dockerfile for your redis container.

The mapped directory should be writable, as depending on the configuration and mode of operation, Redis may need to create additional configuration files or rewrite existing ones.
32bit variant

This variant is not a 32bit image (and will not run on 32bit hardware), but includes Redis compiled as a 32bit binary, especially for users who need the decreased memory requirements associated with that. See "Using 32 bit instances" in the Redis documentation for more information.
## Redis Modules

You can find the list of modules for Redis on redis.io or on redismodules.com. A few of the standard modules can be found here:

    RediSearch: Search and Query with Indexing on Redis
    ReJSON: Extended JSON processing for Redis
    ReBloom: Bloom Filters data type for membership/existence search on Redis

## Image Variants

The redis images come in many flavors, each designed for a specific use case.
redis:<version>

This is the defacto image. If you are unsure about what your needs are, you probably want to use this one. It is designed to be used both as a throw away container (mount your source code and start the container to start your app), as well as the base to build other images off of.

Some of these tags may have names like bullseye in them. These are the suite code names for releases of Debian and indicate which release the image is based on. If your image needs to install any additional packages beyond what comes with the image, you'll likely want to specify one of these explicitly to minimize breakage when there are new releases of Debian.
redis:<version>-alpine

This image is based on the popular Alpine Linux project, available in the alpine official image. Alpine Linux is much smaller than most distribution base images (~5MB), and thus leads to much slimmer images in general.

This variant is useful when final image size being as small as possible is your primary concern. The main caveat to note is that it does use musl libc instead of glibc and friends, so software will often run into issues depending on the depth of their libc requirements/assumptions. See this Hacker News comment thread for more discussion of the issues that might arise and some pro/con comparisons of using Alpine-based images.

To minimize image size, it's uncommon for additional related tools (such as git or bash) to be included in Alpine-based images. Using this image as a base, add the things you need in your own Dockerfile (see the alpine image description for examples of how to install packages if you are unfamiliar).
