# docker-snort

[Snort](https://www.snort.org/) in Docker

The Snort Version 2.9.8.0 and DAQ Version 2.0.6

Modification of https://github.com/John-Lin/docker-snort to include more recent rule set,

removes some Python functionality, and runs on Ubuntu 18.04.

# Docker Usage
You may need to run as `sudo`

Attach the snort in container to have full access to the network

```
$ docker run -it --rm --net=host dvbridges/docker-snort:1.0 /bin/bash
```

# Snort Usage

For testing it's work, start snort and ping the container (for alert, see `/etc/snort/rules/local.rules`)

Start snort

```
$ snort -i <network interface> -c /etc/snort/etc/snort.conf -A console
```

From another terminal, ping the container, and the alert should appear in the containers console.

```
ping 8.8.8.8
```
