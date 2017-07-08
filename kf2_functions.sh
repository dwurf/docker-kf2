function require_steamcmd() {
    # Download/extract steam
    mkdir -p downloads
    [[ -f downloads/steamcmd_linux.tar.gz ]] || \
        wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz -P downloads
    [[ -f steamcmd.sh ]] || tar xzvf downloads/steamcmd_linux.tar.gz
    
    ./steamcmd.sh +exit
}

function require_kf2() {
    # Download kf2
    [[ -f kf2server/Binaries/Win64/KFServer.exe ]] || \
        ./steamcmd.sh \
            +login anonymous \
            +force_install_dir ./kf2server \
            +app_update 232130 validate \
            +exit
}

function update() {
    ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ./kf2server \
        +app_update 232130 \
        +exit
}

function validate() {
    ./steamcmd.sh \
        +login anonymous \
        +force_install_dir ./kf2server \
        +app_update 232130 validate \
        +exit
}

function require_config() {
    # Generate INI files
    if [[ ! -f kf2server/KFGame/Config/PCServer-KFGame.ini ]]; then
        kf2server/Binaries/Win64/KFGameSteamServer.bin.x86_64 kf-bioticslab?difficulty=0?adminpassword=secret?gamepassword=secret -port=7777 &
        sleep 20
        kfpid=$(pgrep -f port=7777)
        kill $kfpid
    fi

}

function load_config() {

    ## Load defaults if nothing has been set

    
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


    ## Now we edit the config files to set the config
    sed -i "s/^GameLength=.*/GameLength=$KF_GAME_LENGTH\r/" kf2server/KFGame/Config/LinuxServer-KFGame.ini
    sed -i "s/^ServerName=.*/ServerName=$KF_SERVER_NAME\r/" kf2server/KFGame/Config/LinuxServer-KFGame.ini
    sed -i "s/^bEnabled=.*/bEnabled=$KF_ENABLE_WEB\r/" kf2server/KFGame/Config/KFWeb.ini
}

function launch() {
    export WINEDEBUG=fixme-all
    local cmd

    cmd="kf2server/Binaries/Win64/KFGameSteamServer.bin.x86_64 "
    cmd+="$KF_MAP"
    cmd+="?Difficulty=$KF_DIFFICULTY"
    cmd+="?AdminPassword=$KF_ADMIN_PASS"
    [[ -z "$KF_GAME_PASS" ]] || cmd+="?GamePassword=$KF_GAME_PASS"
    cmd+=" -Port=7777"
    cmd+=" -WebAdminPort=8080"
    cmd+=" -QueryPort=27015"

    echo "Running command: $cmd" > $0-cmd.log
    exec $cmd
}
