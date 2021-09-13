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

**RHEL Host Nodes**
------------
A couple of amendments specific to RHEL and any offshoots:

To allow an IPv4 address to be shared with containers on a RHEL host, you need to ensure that `net.ipv4.ip_forward` is enabled. This can be set using `sysctl -w net.ipv4.ip_forward=1`. Afterwards, you must restart docker `systemctl restart docker` or `service docker restart` depending on if you are using init.d or systemd.

With docker `-v` mounts you can add `:z` to the end of the mount argument to add the relevant SELinux contexts to use the bind mount automatically. For example `-v $HOME/kf2:/home/steam/kf2server` becomes `-v $HOME/kf2:/home/steam/kf2server:z`.


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

| Variable              | Default           | Description                                                                                                                                                                                                |
|-----------------------|-------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `KF_MAP`              | `KF-BioticsLab`   | Starting map when the server is first loaded.                                                                                                                                                              |
| `KF_DIFFICULTY`       | `0`               | Game difficulty.  * 0 - normal * 1 - hard * 2 - suicidal * 3 - hell on earth                                                                                                                               |
| `KF_ADMIN_PASS`       | `secret`          | Used for web console and in-game admin logins.                                                                                                                                                             |
| `KF_GAME_PASS`        | `''`              | The password used to access the game. Setting this will make the server "private".                                                                                                                         |
| `KF_GAME_LENGTH`      | `1`               | The length of the game. * 0 - 4 waves * 1 - 7 waves * 2 - 10 waves                                                                                                                                         |
| `KF_GAME_MODE`        | `Survival`        | The gametype to use. * Survival * VersusSurvival * WeeklySurvival * Endless                                                                                                                                |
| `KF_PORT`             | `7777`            | The game port (UDP) used to accept incoming clients. This is the port entered in the ingame console's `open` command.                                                                                      |
| `KF_QUERY_PORT`       | `KF_PORT + 19238` | The query port used to this server instance.                                                                                                                                                               |
| `KF_MUTATORS`         | `''`              | If the mutators are correctly installed on the server they can be used like this: `mutator=ClassicScoreboard.ClassicSCMut,KFMutator.KFMutator_MaxPlayersV2` Multiple mutators must be seperated with a `,` |
| `KF_SERVER_NAME`      | `KF2`             | The server name to display in the server browser.                                                                                                                                                          |
| `KF_ENABLE_WEB`       | `false`           | A boolean toggle for the web interface hosted on the KF_WEBADMIN_PORT (default 8080) If setting this to true, it's recommended you change the `KF_ADMIN_PASS` variable too.                                |
| `KF_WEBADMIN_PORT`    | `8080`            | The port used to access the web admin interface.                                                                                                                                                           |
| `KF_DISABLE_TAKEOVER` | `false`           | Allows the server to be used by other players looking to create a private game when the server is uninhabited.                                                                                             |
| `KF_BANNER_LINK`      | `http:\/\/art.tripwirecdn.com\/TestItemIcons\/MOTDServer.png` | A link to a PNG file to display on the server welcome page. You must escape special characters. |
| `KF_MOTD`             | `Welcome to our server. \n \n Have fun and good luck!` | A MOTD message to show under the banner image on the welcome page. You must escape special characters. |
| `KF_WEBSITE_LINK` | `http:\/\/killingfloor2.com` | A website link shown at the bottom of the srver welcome page to allow the visitor to go to your site. You must escape special characters. |
| `MULTIHOME_IP` | `''` | Sets the IP to run the server on in cases where it has been assigned multiple public IPs. |

**NOTE:** Special characters are anything that `sed` considers special, so /, ^, \, * etc. To escape the character, prepend \ before it as in the examples provided in the compose files and above.


Running multiple servers
------------------------

1. Ensure 'command' in docker-compose.yml is not present. Updates will be
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

Find the map you wish to use on the Steam workshop, for example [https://steamcommunity.com/sharedfiles/filedetails/?id=1551913612][]. Note the ID argument from the URL (1551913612) and the name of the map (KF-NachtDerUntoten_TraderPod) and add this to a `game.yml` file in the root directory using the `custommaps` property, like so:

```
custommaps:
  - name: "KF-NachtDerUntoten_TraderPod",
    steamworksids:
      - 1551913612
```

At runtime, the configuration files will be written and will include the map alongside the defaults. A number of things are possible to set for each map added. These are listed below:

| Property             | Default                                     | Description                                                                                                                                                                                |
|----------------------|---------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| name                 | N/A                                         | Must be set otherwise the configuration will not be generated. The name of the map you're adding, per it's name in the Cache directory of the server.                                      |
| steamworksids        | N/A                                         | Must be set in order to download the map at runtime. An array of IDs provided to the KFEngine ini file to download the relevant map. This can be set to multiple things for accessibility. |
| mapfilename          | `name`                                      | The name of the file used for the KFMapSummary section mapname. Can be set differently for accessibility.                                                                                  |
| screenshot           | UI_MapPreview_TEX.UI_MapPreview_Placeholder | The thumbnail image to use for the map.                                                                                                                                                    |
| playableInSurvival   | true                                        | Determines if the map can be played in survival mode.                                                                                                                                      |
| playableInWeekly     | true                                        | Determines if the map can be played in weekly mode.                                                                                                                                        |
| playableInEndless    | true                                        | Determines if the map can be played in endless mode.                                                                                                                                       |
| playableInVsSurvival | true                                        | Determines if the map can be played in vs survival mode.                                                                                                                                   |
| playableInObjective  | true                                        | Determines if the map can be played in objective mode.                                                                                                                                     |
| mapAssociation       | 1                                           | Determines if the map is official (2) or custom (1). This should almost always be 1 but is settable for accessibility.                                                                     |




Building the image
------------------

    docker build -t dwurf/docker-kf2:latest .

Similar projects
----------------

* [KF1 server in Docker](https://github.com/Vel-San/killing-floor-docker)

TODO
----

* Add support for running multiple KF2 servers from the one directory
* Map logs and config to another volume(s)
* This is docker, we shouldn't need logs (use `docker logs`) and config should be done via env variables (i.e. move the config file outside of the volume but it doesn't need to be exposed)
* See also ConfigSubDir under https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)#Command_Line_Launch_Options
* Add support for custom map cycles https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_(Killing_Floor_2)#Maps


