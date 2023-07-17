FROM steamcmd/steamcmd:latest

RUN set -x \
    && apt-get update  \
    && echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections \
    && apt-get install apt-utils -y  \
    && DEBIAN_FRONTEND=noninteractive \
    && apt-get install software-properties-common -y \
    && apt-get install lib32gcc-s1 -y \
    && apt-get install xdg-user-dirs -y \
    && apt-get install -yq gosu ca-certificates locales tzdata \
    && ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -ms /bin/bash steam \
    && gosu nobody true

RUN mkdir -p /config  \
    && mkdir -p /config/gamefiles \
    && mkdir -p /home/steam/.steam/  \
    && chown steam:steam -R /config

COPY init.sh /
COPY ini2/*.ini run.sh init.sh /home/steam/
# COPY /gamefiles /config/gamefiles
WORKDIR /config

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    USER=root \
    HOME=/root \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    TZ=America/Sao_Paulo \
    AUTOPAUSE=false  \
    AUTOSAVEINTERVAL=300\
    AUTOSAVENUM=5 \
    AUTOSAVEONDISCONNECT=true \
    CRASHREPORT=true \
    DEBUG=false \
    DISABLESEASONALEVENTS=false \
    GAMECONFIGDIR=/config/gamefiles/FactoryGame/Saved \
    GAMESAVESDIR=/home/steam/.config/Epic/FactoryGame/Saved/SaveGames \
    MAXOBJECTS=2162689 \
    MAXPLAYERS=4 \
    MAXTICKRATE=120 \
    NETWORKQUALITY=3 \
    PGID=1000 \
    PUID=1000 \
    SERVERBEACONPORT=15000 \
    SERVERGAMEPORT=7777 \
    SERVERIP=0.0.0.0 \
    SERVERQUERYPORT=15777 \
    SKIPUPDATE=false \
    STEAMAPPID=1690800 \
    STEAMBETA=true \
    DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    TIMEOUT=300.0

## Realizar o primeiro download do jogo e steam.
## 1690800 = Satisfactory Dedicated Server
# RUN steamcmd +force_install_dir /config/gamefiles +login anonymous +app_update 1690800 -beta public experimental +quit

EXPOSE 7777/udp 15000/udp 15777/udp
ENTRYPOINT ["/bin/bash","/init.sh"]

# Cria a imagem
# docker build -t satisfactory_tet:1.0 .
# Executa / cria o container
# docker run -it satisfactory_tet:2.1 bash
# docker run -it -p 7777:7777/udp -p 15000:15000/udp -p 15777:15777/udp satisfactory_tet:2.1 bash
# docker run -d --name=satisfactory-server -h satisfactory-server -v /opt/SaveGames:/config/saved -p 7777:7777/udp -p 15000:15000/udp -p 15777:15777/udp satisfactory_tet:3.0
# Cria o container e executa o script de inicialização via docker-compose
# docker-compose -f docker-compose.yml up
#
#
# docker build -t satisfactory_tet:2.2 . ; docker run -it satisfactory_tet:2.2 bash
# docker build -t satisfactory_tet:3.0 . ; docker run -it satisfactory_tet:3.0 bash