FROM anapsix/alpine-java:8_server-jre

# NOTE ca-certificates:
# https://hackernoon.com/alpine-docker-image-with-secured-communication-ssl-tls-go-restful-api-128eb6b54f1f
RUN apk update && \
    apk add ca-certificates wget

RUN mkdir -p /home/ftb && cd /home/ftb

# change directory to /home/ftb
WORKDIR /home/ftb

# download FTB Revelations server pack (latest)
RUN wget http://ftb-latest-url.herokuapp.com -O url.txt && \
    wget -i url.txt -O server.zip && \
    unzip server.zip

# setup the server
# make scripts executable
RUN chmod u+x FTBInstall.sh ServerStart.sh settings.sh

# agree to the EULA
RUN echo "eula=TRUE" >> eula.txt

# modify settings
RUN echo 'export MIN_RAM="2048M"' >> settings.sh && \
    echo 'export MAX_RAM="4096M"' >> settings.sh && \
    echo 'export JAVA_PARAMETERS="-XX:+UseG1GC -XX:+UseStringDeduplication -XX:+DisableExplicitGC -XX:MaxGCPauseMillis=10 -XX:SoftRefLRUPolicyMSPerMB=10000 -XX:ParallelGCThreads=4"' >> settings.sh

# clear out mods which we are upgrading
WORKDIR /home/ftb/mods
RUN rm mcjtylib* && rm rftools-*

# upgrade mods
RUN wget http://ftb-latest-url.herokuapp.com/mods -O mods.txt && \
    wget -i mods.txt

WORKDIR /home/ftb

RUN ./FTBInstall.sh
RUN ./settings.sh
EXPOSE 25565

VOLUME /home/ftb/

CMD ./ServerStart.sh