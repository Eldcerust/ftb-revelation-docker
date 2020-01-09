FROM adoptopenjdk/openjdk8:alpine

# NOTE ca-certificates:
# https://hackernoon.com/alpine-docker-image-with-secured-communication-ssl-tls-go-restful-api-128eb6b54f1f

RUN mkdir -p /home/ftb && cd /home/ftb

# change directory to /home/ftb
WORKDIR /home/ftb

# download FTB Revelations server pack (latest)
RUN wget -q https://media.forgecdn.net/files/2690/320/FTB+Presents+Direwolf20+1.12-1.12.2-2.5.0-Server.zip -O server.zip && \
    unzip server.zip && rm server.zip

# setup the server
# make scripts executable
RUN chmod u+x FTBInstall.sh ServerStart.sh settings.sh

# agree to the EULA
RUN echo "eula=TRUE" >> eula.txt

# modify settings
RUN echo 'export MIN_RAM="4096M"' >> settings.sh && \
    echo 'export MAX_RAM="5000M"' >> settings.sh && \
    echo 'export JAVA_PARAMETERS="-XX:+UseG1GC -XX:+UseStringDeduplication -XX:+DisableExplicitGC -XX:MaxGCPauseMillis=10 -XX:SoftRefLRUPolicyMSPerMB=10000 -XX:ParallelGCThreads=4"' >> settings.sh

# clear out mods which we are upgrading
WORKDIR /home/ftb/mods
RUN rm mcjtylib* && rm rftools-*

# upgrade mods
RUN wget -q https://ftb-mod-lists.herokuapp.com/ -O mods.txt && \
    wget -q -i mods.txt

WORKDIR /home/ftb

RUN ./FTBInstall.sh
RUN ./settings.sh
EXPOSE 25565

VOLUME /home/ftb/

CMD ./ServerStart.sh
