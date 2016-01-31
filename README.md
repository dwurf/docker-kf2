docker-kf2
==========

Dockerfile for running a Killing Floor 2 server. Uses wine.

Requirements
------------

2GB RAM and 10GB free disk space are essential. SSD recommended, otherwise map
changes will take a long time. Disk space requirements will keep going up as 
updates are released.

Simple start
------------

    docker run -d --name kf2 -p 0.0.0.0:20560:20560/udp \
        -p 0.0.0.0:27015:27015/udp \
        -p 0.0.0.0:7777:7777/udp \
        -p 0.0.0.0:8080:8080 \
        -v $HOME/kf2:/kf2 \
        dwurf/kf2:latest

Go do something else for a while, this will take quite some time.

Once the container is created, you might like to stop the container and change
the variables in `$HOME/kf2/config.sh` to your liking (default map, 
difficulty, etc)...

You can also set the following variable names in 
`$HOME/KF2/KFGame/Config/PCServer-KFGame.ini`

    ServerMOTD=Welcome to our server. \n \n Have fun and good luck!
    
    ServerName=Killing Floor 2 Server

and in `$HOME/KF2/KFGame/Config/KFWeb.ini` you can turn on the web console:

    bEnabled=true

Building the image
------------------

    docker build .

