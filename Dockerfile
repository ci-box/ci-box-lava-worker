ARG version=latest
FROM lavasoftware/lava-dispatcher:${version}

ARG extra_packages=""
RUN apt -q update && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install ${extra_packages} net-tools

ARG server=lava-server
RUN echo "MASTER_URL=\"tcp://${server}:5556\"" >> /etc/lava-dispatcher/lava-slave
RUN echo "LOGGER_URL=\"tcp://${server}:5555\"" >> /etc/lava-dispatcher/lava-slave

ENTRYPOINT ["/root/entrypoint.sh"]
