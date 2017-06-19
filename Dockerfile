FROM ubuntu:xenial

RUN apt-get -y update && apt-get -y install wget lib32gcc1

RUN useradd -m steam

WORKDIR /home/steam
USER steam

ADD kf2_functions.sh kf2_functions.sh 
ADD main main 

# Steam port range (only 1 required)
EXPOSE 20560-20579/udp

# Query port - used to communicate with the master server
EXPOSE 27015/udp

# Game port range (only 1 required) - primary comms with players
EXPOSE 7777-7796/udp

# Web Admin port
EXPOSE 8080/tcp

# Steam install is stored here
VOLUME /home/steam/steamcmd

# Game files are stored here
VOLUME /home/steam/kf2server

CMD ["/bin/bash", "main"]

