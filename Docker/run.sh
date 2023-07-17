#!/bin/bash

set -e
chmod 744 ${GAMECONFIGDIR}/Config/LinuxServer/*.ini
set_ini_prop() {
    sed "/\[$2\]/,/^\[/ s/$3\=.*/$3=$4/" -i "/home/steam/$1"
}

set_ini_val() {
    sed "s/\(\"$2\", \)[0-9]*/\1$3/" -i "/home/steam/$1"
}

NUMCHECK='^[0-9.]+$'
echo "------------------------------------------------------------------------------------------------------------"
## START Engine.ini
if ! [[ "$AUTOSAVENUM" =~ $NUMCHECK ]]; then
    printf "Número de salvamento automático inválido fornecido: %s\\n" "$AUTOSAVENUM"
    AUTOSAVENUM="3"
fi
printf "Configurando o número de salvamento automático para %s\\n" "$AUTOSAVENUM"
set_ini_prop "Engine.ini" "\/Script\/FactoryGame\.FGSaveSession" "mNumRotatingAutosaves" "$AUTOSAVENUM"

[[ "${CRASHREPORT,,}" == "true" ]] && CRASHREPORT="true" || CRASHREPORT="false"
printf "Configurando o relatório de falhas para %s\\n" "${CRASHREPORT^}"
set_ini_prop "Engine.ini" "CrashReportClient" "bImplicitSend" "${CRASHREPORT^}"

if ! [[ "$MAXOBJECTS" =~ $NUMCHECK ]]; then
    printf "Número máximo de objetos inválido fornecido: %s\\n" "$MAXOBJECTS"
    MAXOBJECTS="2162688"
fi
printf "Configurando o número máximo de objetos para %s\\n" "$MAXOBJECTS"
set_ini_prop "Engine.ini" "\/Script\/Engine\.GarbageCollectionSettings" "gc.MaxObjectsInEditor" "$MAXOBJECTS"
set_ini_prop "Engine.ini" "\/Script\/Engine\.GarbageCollectionSettings" "gc.MaxObjectsInGame" "$MAXOBJECTS"

if ! [[ "$MAXTICKRATE" =~ $NUMCHECK ]]; then
    printf "Número de taxa máxima de ticks inválido fornecido: %s\\n" "$MAXTICKRATE"
    MAXTICKRATE="120"
fi
printf "Configurando a taxa máxima de ticks para %s\\n" "$MAXTICKRATE"
set_ini_prop "Engine.ini" "\/Script\/OnlineSubsystemUtils.IpNetDriver" "NetServerMaxTickRate" "$MAXTICKRATE"
set_ini_prop "Engine.ini" "\/Script\/OnlineSubsystemUtils.IpNetDriver" "LanServerMaxTickRate" "$MAXTICKRATE"

if ! [[ "$TIMEOUT" =~ $NUMCHECK ]]; then
    printf "Número de tempo limite inválido fornecido: %s\\n" "$TIMEOUT"
    TIMEOUT="300"
fi
printf "Configurando o número de tempo limite para %s\\n" "$TIMEOUT"
set_ini_prop "Engine.ini" "\/Script\/OnlineSubsystemUtils\.IpNetDriver" "ConnectionTimeout" "$TIMEOUT"
set_ini_prop "Engine.ini" "\/Script\/OnlineSubsystemUtils\.IpNetDriver" "InitialConnectTimeout" "$TIMEOUT"
## END Engine.ini

## START Game.ini
# Finish setting timeout from Engine.ini
set_ini_prop "Game.ini" "\/Script\/Engine\.GameSession" "ConnectionTimeout" "$TIMEOUT"
set_ini_prop "Game.ini" "\/Script\/Engine\.GameSession" "InitialConnectTimeout" "$TIMEOUT"

if ! [[ "$MAXPLAYERS" =~ $NUMCHECK ]]; then
    printf "Jogadores máximos inválidos dados: %s\\n" "$MAXPLAYERS"
    MAXPLAYERS="4"
fi
printf "Configurando o máximo de jogadores para %s\\n" "$MAXPLAYERS"
set_ini_prop "Game.ini" "\/Script\/Engine\.GameSession" "MaxPlayers" "$MAXPLAYERS"
## END Game.ini

## START GameUserSettings.ini
if ! [[ "$AUTOSAVEINTERVAL" =~ $NUMCHECK ]]; then
    printf "Intervalo de salvamento automático inválido fornecido: %s\\n" "$AUTOSAVEINTERVAL"
    AUTOSAVEINTERVAL="300"
fi
printf "Configurando o intervalo de salvamento automático para %ss\\n" "$AUTOSAVEINTERVAL"
set_ini_val "GameUserSettings.ini" "FG.AutosaveInterval" "$AUTOSAVEINTERVAL"

[[ "${DISABLESEASONALEVENTS,,}" == "true" ]] && DISABLESEASONALEVENTS="1" || DISABLESEASONALEVENTS="0"
printf "Configurando desabilitar eventos sazonais para %s\\n" "$DISABLESEASONALEVENTS"
set_ini_val "GameUserSettings.ini" "FG.DisableSeasonalEvents" "$DISABLESEASONALEVENTS"

if ! [[ "$NETWORKQUALITY" =~ $NUMCHECK ]]; then
    printf "Número de qualidade de rede inválido fornecido: %s\\n" "$NETWORKQUALITY"
    NETWORKQUALITY="3"
fi
printf "Configurando o número de qualidade da rede para %s\\n" "$NETWORKQUALITY"
set_ini_prop "GameUserSettings.ini" "\/Script\/FactoryGame\.FGGameUserSettings" "mNetworkQuality" "$NETWORKQUALITY"
set_ini_val "GameUserSettings.ini" "FG.NetworkQuality" "$NETWORKQUALITY"
## END GameUserSettings.ini

## START ServerSettings.ini
[[ "${AUTOPAUSE,,}" == "true" ]] && AUTOPAUSE="true" || AUTOPAUSE="false"
printf "Configurando a pausa automática para %s\\n" "${AUTOPAUSE^}"
set_ini_prop "ServerSettings.ini" "\/Script\/FactoryGame\.FGServerSubsystem" "mAutoPause" "${AUTOPAUSE^}"

[[ "${AUTOSAVEONDISCONNECT,,}" == "true" ]] && AUTOSAVEONDISCONNECT="true" || AUTOSAVEONDISCONNECT="false"
printf "Configurando o salvamento automático ao desconectar para %s\\n" "${AUTOSAVEONDISCONNECT^}"
set_ini_prop "ServerSettings.ini" "\/Script\/FactoryGame\.FGServerSubsystem" "mAutoSaveOnDisconnect" "${AUTOSAVEONDISCONNECT^}"
## END ServerSettings.ini

if ! [[ "${SKIPUPDATE,,}" == "true" ]]; then
    if [[ "${STEAMBETA,,}" == "true" ]]; then
        printf "O sinalizador experimental está definido. Experimental será baixado em vez de Acesso Antecipado.\\n"
        STEAMBETAFLAG="experimental"
    else
        STEAMBETAFLAG="public"
    fi

    STORAGEAVAILABLE=$(stat -f -c "%a*%S" .)
    STORAGEAVAILABLE=$((STORAGEAVAILABLE / 1024 / 1024 / 1024))
    printf "Verificando o armazenamento disponível...%sGB detectado\\n" "$STORAGEAVAILABLE"

    if [[ "$STORAGEAVAILABLE" -lt 8 ]]; then
        printf "Você tem menos de 8 GB (%sGB detectados) de armazenamento disponível para baixar o jogo.\\nSe esta for uma nova instalação, provavelmente falhará.\\n" "$STORAGEAVAILABLE"
    fi

    printf "Baixando a última versão do jogo...\\n"

    steamcmd +force_install_dir /config/gamefiles +login anonymous +app_update "$STEAMAPPID" -beta "$STEAMBETAFLAG" validate +quit
else
    printf "Ignorando a atualização quando o sinalizador é definido\\n"
fi

# migração temporária para novo formato
if [ -d "/config/blueprints" ]; then
    if [ -n "$(ls -A "/config/blueprints" 2>/dev/null)" ]; then
        rm -rf "/config/saved/blueprints"
        mv "/config/blueprints" "/config/saved/blueprints"
    else
        rm -rf "/config/blueprints"
    fi
fi

if [ -d "/config/saves" ]; then
    if [ -n "$(ls -A "/config/saves" 2>/dev/null)" ]; then
        find "/config/saves/" -type f -print0 | xargs -0 mv -t "/config/saved/server" || exit 1
    else
        rmdir "/config/saves"
    fi
fi

if [ -f "/config/ServerSettings.${SERVERQUERYPORT}" ]; then
    mv "/config/ServerSettings.${SERVERQUERYPORT}" "/config/saved/ServerSettings.${SERVERQUERYPORT}"
fi

# migração temporária para novo formato
cp -r "/config/saved/server/." "/config/backups/"
cp -r "${GAMESAVESDIR}/server/." "/config/backups" # useful after the first run
rm -rf "$GAMESAVESDIR"
ln -sf "/config/saved" "$GAMESAVESDIR"
cp /home/steam/*.ini "${GAMECONFIGDIR}/Config/LinuxServer/"
chmod 444 ${GAMECONFIGDIR}/Config/LinuxServer/*.ini

if [ ! -f "/config/gamefiles/FactoryServer.sh" ]; then
    printf "O script de inicialização do FactoryServer está ausente.\\n"
    exit 1
fi
echo "------------------------------------------------------------------------------------------------------------"

if [ -e "/config/gamefiles/Engine/Binaries/ThirdParty/Steamworks/Steamv147/x86_64-unknown-linux-gnu/libsteam_api.so" ]; then
    cp /config/gamefiles/Engine/Binaries/ThirdParty/Steamworks/Steamv147/x86_64-unknown-linux-gnu/libsteam_api.so /config/gamefiles/Engine/Binaries/Linux/
fi

cd /config/gamefiles || exit 1
exec ./FactoryServer.sh -log -NoSteamClient -unattended ?listen -Port="$SERVERGAMEPORT" -BeaconPort="$SERVERBEACONPORT" -ServerQueryPort="$SERVERQUERYPORT" -multihome="$SERVERIP" "$@"
