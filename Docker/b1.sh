#!/bin/bash
steamcmd +force_install_dir /config/gamefiles +login anonymous +app_update "$STEAMAPPID" -beta "experimental" validate +quit

cd /config/gamefiles || exit 1
exec ./Engine/Binaries/Linux/UnrealServer-Linux-Shipping FactoryGame -log -NoSteamClient -unattended ?listen -Port="$SERVERGAMEPORT" -BeaconPort="$SERVERBEACONPORT" -ServerQueryPort="$SERVERQUERYPORT" -multihome="$SERVERIP" "$@"
