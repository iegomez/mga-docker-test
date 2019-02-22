FROM ubuntu:latest
RUN apt-get update && apt-get install -y supervisor libwebsockets8 libwebsockets-dev libc-ares2 libc-ares-dev openssl uuid uuid-dev wget build-essential
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir loraserver lora-app-server mosquitto
RUN mkdir mosquitto/auth mosquitto/conf.d
RUN mkdir .config .config/loraserver .config/lora-app-server

RUN mkdir /etc/loraserver
RUN mkdir /etc/lora-app-server

COPY loraserver /loraserver/loraserver
COPY lora-app-server lora-app-server/lora-app-server
COPY configuration/loraserver.toml /etc/loraserver/loraserver.toml
COPY configuration/lora-app-server.toml /etc/lora-app-server/lora-app-server.toml

RUN wget http://mosquitto.org/files/source/mosquitto-1.5.3.tar.gz
RUN tar xzvf mosquitto-1.5.3.tar.gz

RUN mkdir -p /var/lib/mosquitto
RUN mkdir -p /var/log/mosquitto 

RUN cd mosquitto-1.5.3 && make WITH_WEBSOCKETS=yes && make install && cd ..
RUN groupadd mosquitto
RUN useradd -s /sbin/nologin mosquitto -g mosquitto -d /var/lib/mosquitto
RUN chown -R mosquitto:mosquitto /var/log/mosquitto/
RUN chown -R mosquitto:mosquitto /var/lib/mosquitto/

COPY go-auth.so mosquitto/go-auth.so
COPY mosquitto.conf mosquitto/mosquitto.conf
COPY go-auth.conf mosquitto/conf.d/go-auth.conf
COPY auth/acls mosquitto/auth/acls
COPY auth/passwords mosquitto/auth/passwords

EXPOSE 1883 1884 8080

CMD ["/usr/bin/supervisord"]