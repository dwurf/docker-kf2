FROM ubuntu:eoan

RUN \
	apt-get -y update && \
	apt-get -y install wget lib32gcc1 libcurl4 && \
	apt-get clean && \
	find /var/lib/apt/lists -type f | xargs rm -vf

RUN useradd -m steam

WORKDIR /home/steam
USER steam

ADD kf2_functions.sh kf2_functions.sh 
ADD main main 

# Steam port
EXPOSE 20560/udp

# Query port - used to communicate with the master server
EXPOSE 27015/udp

# Game port - primary comms with players
EXPOSE 7777/udp

# Web Admin port
EXPOSE 8080/tcp

ENTRYPOINT ["/bin/bash", "main"]

