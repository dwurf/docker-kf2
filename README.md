docker-kf2
==========

Dockerfile for running a Killing Floor 2 server

Requirements
------------

2GB RAM and 30GB free disk space are essential. SSD recommended, otherwise map
changes will take a long time. Disk space requirements will keep going up as 
updates are released.

Simple start
------------

    docker run -d -t --name kf2 -p 0.0.0.0:20560:20560/udp \
        -p 0.0.0.0:27015:27015/udp \
        -p 0.0.0.0:7777:7777/udp \
        -p 0.0.0.0:8080:8080 \
        -v $HOME/kf2:/home/steam/kf2server \
        dwurf/docker-kf2:latest

Configuring the server
----------------------

Configuration is done via environment variables. To run a long, hard server:

    docker run -d -t --name kf2 -p 0.0.0.0:20560:20560/udp \
        -p 0.0.0.0:27015:27015/udp \
        -p 0.0.0.0:7777:7777/udp \
        -p 0.0.0.0:8080:8080 \
        -v $HOME/kf2:/home/steam/kf2server \
        -e KF_DIFFICULTY=1 \
        -e KF_GAME_LENGTH=2 \
        dwurf/docker-kf2:latest

Variables
---------

`KF_MAP` (default: `KF-BioticsLab`)

Starting map when the server is first loaded

`KF_DIFFICULTY` (default: `0`)

Game difficulty. 

* 0 - normal
* 1 - hard
* 2 - suicidal
* 3 - hell on earth

`KF_ADMIN_PASS` (default: `secret`)

Used for web console and in-game admin logins

`KF_GAME_PASS` (default: `''`)

Setting this creates a private server

`KF_GAME_LENGTH` (default: `1`)

* 0 - 4 waves
* 1 - 7 waves
* 2 - 10 waves

`KF_SERVER_NAME` (default: `Killing Floor 2 Server`)

Name that appears in the server browser

`KF_ENABLE_WEB` (default: `false`)

Set to `true` to enable the web console. You should probably also change the
default admin password
Access the web console on port 8080, the username is `admin`, the password is
set to `KF_ADMIN_PASS` (default: `secret`)

Building the image
------------------

    docker build -t dwurf/docker-kf2:latest .

TODO
----

* Add support for running multiple KF2 servers from the one directory
 * Map logs and config to another volume(s)
  * This is docker, we shouldn't need logs (use `docker logs`) and config should be done via env variables (i.e. move the config file outside of the volume but it doesn't need to be exposed)
 * See also ConfigSubDir under https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)#Command_Line_Launch_Options
* Add support for custom map cycles https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)#Maps
* Steam workshop support https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)#Setting_Up_Steam_Workshop_For_Servers
* Server welcome screen https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)#Setting_Up_Server_Welcome_Screen


