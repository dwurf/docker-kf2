function require_steamcmd() {
    # Download/extract steam
    mkdir -p downloads
    [[ -f downloads/steamcmd.zip ]] || \
        wget http://media.steampowered.com/installer/steamcmd.zip -P downloads
    [[ -f steamcmd.exe ]] || unzip -o downloads/steamcmd.zip
    
    # Install/update steam
    WINEDEBUG=fixme-all wine steamcmd.exe +exit
}

function require_kf2() {
    # Download kf2
    [[ -f kf2server/Binaries/Win64/KFServer.exe ]] || \
        WINEDEBUG=fixme-all \
        wine steamcmd.exe \
            +login anonymous \
            +force_install_dir ./kf2server \
            +app_update 232130 validate \
            +exit
}

function require_dlls() {
    # Download/extract KF2 DLLs
    mkdir -p downloads
    [[ -f downloads/KF2_WineDLL.zip ]] || \
        wget http://www.redorchestra2.fr/downloads/KF2_WineDLL.zip -P downloads

    [[ -f .wine/drive_c/windows/system32/X3DAudio1_7.dll ]] || (
        cd $HOME/.wine/drive_c/windows/system32
        unzip -o $OLDPWD/downloads/KF2_WineDLL.zip
    )

    # Install MS Visual C++ runtime
    [[ -d $HOME/.wine/drive_c/windows/temp/_vcrun2010 ]] || (
        winetricks -q vcrun2010 & sleep 30
    )
}

function update() {
    export WINEDEBUG=fixme-all
    wine steamcmd.exe \
        +login anonymous \
        +force_install_dir \
        ./kf2server \
        +app_update 232130 \
        +exit
}

function validate() {
    export WINEDEBUG=fixme-all
    wine steamcmd.exe \
        +login anonymous \
        +force_install_dir \
        ./kf2server \
        +app_update 232130 validate \
        +exit
}

function require_config() {
    # Generate INI files
    if [[ ! -f kf2server/KFGame/Config/PCServer-KFGame.ini ]]; then
        wine kf2server/Binaries/Win64/KFServer kf-bioticslab?difficulty=0?adminpassword=secret?gamepassword=secret -port=7777 &
        sleep 20
        kfpid=$(pgrep -f port=7777)
        kill $kfpid
    fi

    # Generate local docker config
    if [[ ! -e config.sh ]]; then
        local config
        config="# More configuration options in KFGame/Config/PCServer-KFGame.ini\n"
        config+="# and KFGame/Config/KFWeb.ini\n"
        config+="\n"
        config+="# Run this command for a list of maps:\n"
        config+="# find . -name '*KF-*kfm' | xargs -n 1 basename -s .kfm\n"
        config+="map=KF-BioticsLab\n"
        config+="\n"
        config+="# 0-normal 1-hard 2-suicidal 3-hell on earth\n"
        config+="difficulty=0\n"
        config+="\n"
        config+="admin_password=secret\n"
        config+="\n"
        config+="# Uncomment if you want a private server\n"
        config+="#game_password=secret\n"
        echo -e "$config" >> config.sh
    fi
}

function launch() {
    export WINEDEBUG=fixme-all
    local cmd

    source config.sh

    cmd="wine kf2server/Binaries/Win64/KFServer "
    cmd+="$map"
    cmd+="?Difficulty=$difficulty"
    cmd+="?AdminPassword=$admin_password"
    [[ -z "$game_password" ]] || cmd+="?GamePassword=$game_password"
    cmd+=" -Port=7777"
    cmd+=" -WebAdminPort=8080"
    cmd+=" -QueryPort=27015"

    echo "Running command: $cmd" > $0-cmd.log
    exec $cmd
}
