docker-kf2
==========

Dockerfile for running a Killing Floor 2 server

* GitHub: https://github.com/dwurf/docker-kf2
* Docker Hub: https://hub.docker.com/r/dwurf/docker-kf2/

Requirements
------------

2GB RAM and 20GB free disk space are essential. SSD recommended, otherwise map
changes will take a long time. Disk space requirements will keep going up as 
updates are released.

Simple start
------------

    mkdir -p $HOME/{kf2,kf2_steamdir}
    docker run -d -t --name kf2 -p 0.0.0.0:20560:20560/udp \
        -p 0.0.0.0:27015:27015/udp \
        -p 0.0.0.0:7777:7777/udp \
        -p 0.0.0.0:8080:8080 \
        -v $HOME/kf2:/home/steam/kf2server \
        -v $HOME/kf2_steamdir:/home/steam/steam \
        dwurf/docker-kf2:latest

Configuring the server
----------------------

Configuration is done via environment variables. To run a long, hard server:

    docker run -d -t --name kf2 -p 0.0.0.0:20560:20560/udp \
        -p 0.0.0.0:27015:27015/udp \
        -p 0.0.0.0:7777:7777/udp \
        -p 0.0.0.0:8080:8080 \
        -v $HOME/kf2:/home/steam/kf2server \
        -v $HOME/kf2_steamdir:/home/steam/steam \
        -e KF_DIFFICULTY=1 \
        -e KF_GAME_LENGTH=2 \
        dwurf/docker-kf2:latest

Updating the server
-------------------

Run with the command `update`

    docker run -d -t --name kf2 -p 0.0.0.0:20560:20560/udp \
        -p 0.0.0.0:27015:27015/udp \
        -p 0.0.0.0:7777:7777/udp \
        -p 0.0.0.0:8080:8080 \
        -v $HOME/kf2:/home/steam/kf2server \
        -v $HOME/kf2_steamdir:/home/steam/steam \
        dwurf/docker-kf2:latest \
        update

Further arguments get passed to the update command, e.g.

    docker run -d -t --name kf2 -p 0.0.0.0:20560:20560/udp \
        -p 0.0.0.0:27015:27015/udp \
        -p 0.0.0.0:7777:7777/udp \
        -p 0.0.0.0:8080:8080 \
        -v $HOME/kf2:/home/steam/kf2server \
        -v $HOME/kf2_steamdir:/home/steam/steam \
        dwurf/docker-kf2:latest \
        update -beta preview validate

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

`KF_GAME_MODE` (default: `Survival`)

Options are:

* Survival
* VersusSurvival
* WeeklySurvival
* Endless

`KF_MUTATORS`

If the mutators are correctly installed to the server they can be used like this:
`KFMutator.KFMutator_MaxPlayersV2?MaxPlayers=20?MaxMonsters=85,ClassicScoreboard.ClassicSCMut`
Multiple mutators needs to be seperated with a `,`

`KF_SERVER_NAME` (default: `Killing Floor 2 Server`)

Name that appears in the server browser

`KF_ENABLE_WEB` (default: `false`)

Set to `true` to enable the web console. You should probably also change the
default admin password
Access the web console on port 8080, the username is `admin`, the password is
set to `KF_ADMIN_PASS` (default: `secret`)

`KF_DISABLE_TAKEOVER` (default: `false`)

Set to `true` to prevent randoms from taking over the server. Useful if you've
set a password on your server.

Running multiple servers
------------------------

1. Ensure 'command' in docker-compose.yml is not present. Update swill be
   handled from the first server only.
2. Change ports (increment), set environment variables to match
3. Change server name (optional)

Update the volume mounts as follows:

Map the following read-only volume from server 1

 - $HOME/kf2:/home/steam/kf2server:ro \

Map the following read-write volumes

 - $HOME/kf2-server2/steam/:/home/steam/steam
 - $HOME/kf2-server2/kf2server/KFGame/Logs:/home/steam/kf2server/KFGame/Logs
 - $HOME/kf2-server2/kf2server/KFGame/Config:/home/steam/kf2server/KFGame/Config

These are only required for Steam Workshop maps (see below)

 - $HOME/kf2-server2/kf2server/Binaries/Win64/steamapps:/home/steam/kf2server/Binaries/Win64/steamapps
 - $HOME/kf2-server2/kf2server/KFGame/Cache:/home/steam/kf2server/KFGame/Cache

You *must* also copy the basic config files from server1

    mkdir -p $HOME/kf2-server2/kf2server/KFGame/Config
    cp -a $HOME/kf2/kf2server/KFGame/Config/* $HOME/kf2-server2/kf2server/KFGame/Config

Steam Workshop maps
-------------------

Under `kf2server`, modify the file `KFGame/Config/LinuxServer-KFEngine.ini` as per [Tripwire's wiki][1]

Example shown below is for [Biolapse - Biotics Holdout][2] by 

[1]: https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)#Setting_Up_Steam_Workshop_For_Servers
[2]: http://steamcommunity.com/sharedfiles/filedetails/?id=1258411772


    [OnlineSubsystemSteamworks.KFWorkshopSteamworks]
    ServerSubscribedWorkshopItems=1258411772


You'll also need to add the maps to `LinuxServer-KFGame.ini` as described in the wiki [here][3] and [here][4].

[3]: https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_%28Killing_Floor_2%29#Maps
[4]: https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_%28Killing_Floor_2%29#Get_Custom_Maps_To_Show_In_Web_Admin

Examples:

    [KFGame.KFGameInfo]
    ...
    GameMapCycles=(Maps=("KF-BurningParis","KF-Biolapse"))
    ...

    [KF-Biolapse KFMapSummary]
    MapName=KF-Biolapse
    ScreenshotPathName=UI_MapPreview_TEX.UI_MapPreview_Placeholder


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
* Server welcome screen https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)#Setting_Up_Server_Welcome_Screen


