function require_steamcmd() {
    # Download/extract steam
    mkdir -p "${HOME}/steam/downloads"
    [[ -f "${HOME}/steam/downloads/steamcmd_linux.tar.gz" ]] || \
        wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -P "${HOME}/steam/downloads"
    [[ -f "${HOME}/steam/steamcmd.sh" ]] || (
        cd "${HOME}/steam"
        tar xzvf downloads/steamcmd_linux.tar.gz
    )
    
    (
        cd "${HOME}/steam"
        ./steamcmd.sh +exit
    )
}

function require_ruby() {
  ruby -v
  [[ -f Gemfile ]] && ( \
    bundle install
  )
}

function require_kf2() {
    # Download kf2
    [[ -f "${HOME}/kf2server/Binaries/Win64/KFServer.exe" ]] || ( \
        cd "${HOME}/steam"
        ./steamcmd.sh \
            +login anonymous \
            +force_install_dir "${HOME}/kf2server" \
            +app_update 232130 validate \
            +exit
    )
}

function update() {
    rm -rf "${HOME}/steam/steamapps"
    (
        cd "${HOME}/steam"
        ./steamcmd.sh \
            +login anonymous \
            +force_install_dir "${HOME}/kf2server" \
            +app_update 232130 "$@" \
            +exit
    )
}


function require_config() {
  
    # Generate INI files
    if [[ ! -f "${HOME}/kf2server/KFGame/Config/PCServer-KFGame.ini" ]]; then
        "${HOME}/kf2server/Binaries/Win64/KFGameSteamServer.bin.x86_64" kf-bioticslab?difficulty=0?adminpassword=secret?gamepassword=secret -port=7777 &
        sleep 20
        kfpid=$(pgrep -f port=7777)
        kill $kfpid
        #Workaround as per https://wiki.tripwireinteractive.com/index.php?title=Dedicated_Server_%28Killing_Floor_2%29#Setting_Up_Steam_Workshop_For_Servers
        mkdir -p "${HOME}/kf2server/KFGame/Cache"
    fi

    if [[ -f "${HOME}/game.yml" ]]; then
      (
        cd "${HOME}/configurator"
        ruby GenerateConfig.rb
      )
    fi

}

function load_config() {
    ## Load defaults if nothing has been set

    # Default to survival
    [[ -z "$KF_GAME_MODE" ]] && export KF_GAME_MODE=Survival
    if [[ "$KF_GAME_MODE" == 'VersusSurvival' ]]; then
        KF_GAME_MODE='VersusSurvival?maxplayers=12';
    fi;

    # find /path/to/volume -name '*KF-*kfm' | xargs -n 1 basename -s .kfm\n"
    [[ -z "$KF_MAP" ]] && export KF_MAP=KF-BioticsLab

    # 0 - normal, 1 - hard, 2 - suicidal, 3 - hell on earth
    [[ -z "$KF_DIFFICULTY" ]] && export KF_DIFFICULTY=0

    # Used for web console and in-game logins
    [[ -z "$KF_ADMIN_PASS" ]] && export KF_ADMIN_PASS=secret

    # Setting this creates a private server
    [[ -z "$KF_GAME_PASS" ]] && export KF_GAME_PASS=''

    # 0 - 4 waves, 1 - 7 waves, 2 - 10 waves, default 1
    [[ -z "$KF_GAME_LENGTH" ]] && export KF_GAME_LENGTH=1

    # Name that appears in the server browser
    [[ -z "$KF_SERVER_NAME" ]] && export KF_SERVER_NAME=KF2 Server

    # true or false, default false
    [[ -z "$KF_ENABLE_WEB" ]] && export KF_ENABLE_WEB=false

    # default to 7777
    [[ -z "$KF_PORT" ]] && export KF_PORT=7777

    # default to $(($KF_PORT + 19238))
    #    (19238 = 27015 - 7777)
    [[ -z "$KF_QUERY_PORT" ]] && export KF_QUERY_PORT="$(($KF_PORT + 19238))"

    # default to 8080
    [[ -z "$KF_WEBADMIN_PORT" ]] && export KF_WEBADMIN_PORT=8080

    #default to the URL for the default MOTD
    [[ -z "$KF_BANNER_LINK" ]] && export KF_BANNER_LINK="http://art.tripwirecdn.com/TestItemIcons/MOTDServer.png"

    #default server message
    [[ -z "$KF_MOTD" ]] && export KF_MOTD="Welcome to our server. \n \n Have fun and good luck!"

    #default to killingfloor2.com
    [[ -z "$KF_WEBSITE_LINK" ]] && export KF_WEBSITE_LINK="http://killingfloor2.com/"


    ## Now we edit the config files to set the config
    sed -i "s/^GameLength=.*/GameLength=$KF_GAME_LENGTH\r/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFGame.ini"
    sed -i "s/^ServerName=.*/ServerName=$KF_SERVER_NAME\r/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFGame.ini"
    sed -i "s/^bEnabled=.*/bEnabled=$KF_ENABLE_WEB\r/" "${HOME}/kf2server/KFGame/Config/KFWeb.ini"
    if [[ "${KF_DISABLE_TAKEOVER}" == 'true' ]]; then 
      sed -i "s/^bUsedForTakeover=.*/bUsedForTakeover=FALSE\r/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFEngine.ini"
    else
      sed -i "s/^bUsedForTakeover=.*/bUsedForTakeover=TRUE\r/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFEngine.ini"
    fi
    sed -i "s/^DownloadManagers=IpDrv.HTTPDownload/DownloadManagers=OnlineSubsystemSteamworks.SteamWorkshopDownload/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFEngine.ini"
    sed -i "s/^BannerLink=.*/BannerLink=${KF_BANNER_LINK}/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFGame.ini"
    sed -i "s/^ServerMOTD=.*/ServerMOTD=${KF_MOTD}/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFGame.ini"
    sed -i "s/^WebsiteLink=.*/WebsiteLink=${KF_WEBSITE_LINK}/" "${HOME}/kf2server/KFGame/Config/LinuxServer-KFGame.ini"

}

function launch() {
    export WINEDEBUG=fixme-all
    local cmd

    cmd="${HOME}/kf2server/Binaries/Win64/KFGameSteamServer.bin.x86_64 "
    cmd+="$KF_MAP?Game=KFGameContent.KFGameInfo_$KF_GAME_MODE"
    cmd+="?Difficulty=$KF_DIFFICULTY"
    cmd+="?AdminPassword=$KF_ADMIN_PASS"
    [[ -z "$MULTIHOME_IP" ]] || cmd+="?Multihome=${MULTIHOME_IP}"
    [[ -z "$KF_MUTATORS" ]] || cmd+="?Mutator=$KF_MUTATORS"
    [[ -z "$KF_GAME_PASS" ]] || cmd+="?GamePassword=$KF_GAME_PASS"
    cmd+=" -Port=$KF_PORT"
    cmd+=" -WebAdminPort=$KF_WEBADMIN_PORT"
    cmd+=" -QueryPort=$KF_QUERY_PORT"

    echo "Running command: $cmd" > $0-cmd.log
    exec $cmd
}
