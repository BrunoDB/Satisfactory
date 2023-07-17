#!/bin/bash
echo "nameserver 8.8.8.8" >>/etc/resolv.conf
set -e

CURRENTUID=$(id -u)
NUMCHECK='^[0-9.]+$'
# RAMAVAILABLE=12
RAMAVAILABLE=$(awk '/MemAvailable/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)
USER="steam"

if [[ "$DEBUG" == "true" ]]; then
    printf "Depuração ativada (o contêiner sairá após imprimir as informações de depuração)\\n\\nVariáveis de ambiente de impressão:\\n"
    export

    echo "
Informação do sistema:
OS:  $(uname -a)
CPU: $(lscpu | grep 'Model name:' | sed 's/Model name:[[:space:]]*//g')
RAM: $(awk '/MemAvailable/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB/$(awk '/MemTotal/ {printf( "%d\n", $2 / 1024000 )}' /proc/meminfo)GB
HDD: $(df -h | awk '$NF=="/"{printf "%dGB/%dGB (%s used)\n", $3,$2,$5}')"
    printf "\\nUsuário atual:\\n%s" "$(id)"
    printf "\\nUsuário proposto:\\nuid=%s(?) gid=%s(?) groups=%s(?)\\n" "$PUID" "$PGID" "$PGID"
    printf "\\nExiting...\\n"
    exit 1
fi

if [[ "$CURRENTUID" -ne "0" ]]; then
    printf "O usuário atual não é root (%s)\\nPasse seu usuário e grupo para o contêiner usando as variáveis de ambiente PGID e PUID\\nNão use o sinalizador --user (ou usuário: campo no Docker Compose)\\n" "$CURRENTUID"
    exit 1
fi

printf "Verificando memória disponível...%sGB detectado\\n" "$RAMAVAILABLE"
if [[ "$RAMAVAILABLE" -lt 0 ]]; then
    printf "Você tem menos do que o mínimo necessário de 8 GB (%sGB detectados) de RAM disponível para executar o servidor do jogo.\\nÉ provável que o servidor não carregue corretamente.\\n" "$RAMAVAILABLE"
fi

mkdir -p \
    /config/backups \
    /config/gamefiles \
    /config/saved/blueprints \
    /config/saved/server \
    "${GAMECONFIGDIR}/Config/LinuxServer" \
    "${GAMECONFIGDIR}/Logs" \
    "${GAMESAVESDIR}/server" ||
    exit 1

# verifique se os IDs de usuário e grupo foram definidos
if ! [[ "$PGID" =~ $NUMCHECK ]]; then
    printf "ID de grupo inválido fornecido: %s\\n" "$PGID"
    PGID="1000"
elif [[ "$PGID" -eq 0 ]]; then
    printf "PGID/group não pode ser 0 (root)\\n"
    exit 1
fi

if ! [[ "$PUID" =~ $NUMCHECK ]]; then
    printf "ID de usuário inválido fornecido: %s\\n" "$PUID"
    PUID="1000"
elif [[ "$PUID" -eq 0 ]]; then
    printf "PUID/user não pode ser 0 (root)\\n"
    exit 1
fi

if [[ $(getent group $PGID | cut -d: -f1) ]]; then
    usermod -a -G "$PGID" steam
else
    groupmod -g "$PGID" steam
fi

if [[ $(getent passwd ${PUID} | cut -d: -f1) ]]; then
    USER=$(getent passwd $PUID | cut -d: -f1)
else
    usermod -u "$PUID" steam
fi
echo "--------------------- FIM DO INIT.SH ---------------------"
echo "##########################################################"
chown -R "$PUID":"$PGID" /config /home/steam /tmp/dumps
exec gosu "$USER" "/home/steam/run.sh" "$@"
