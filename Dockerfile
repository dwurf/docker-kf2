FROM ubuntu:trusty

RUN dpkg --add-architecture i386 && \
    apt-get -y update && apt-get -y install wine wget xvfb

WORKDIR /

ADD kf2_functions.sh /kf2_functions.sh 
ADD main /main 

# Steam port
EXPOSE 20560/udp

# Query port - used to communicate with the master server
EXPOSE 27015/udp

# Game port - primary comms with players
EXPOSE 7777/udp

# Web Admin port
EXPOSE 8080/tcp

CMD ["/bin/bash", "/main"]

