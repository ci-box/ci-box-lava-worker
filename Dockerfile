ARG version=latest
FROM lavasoftware/lava-dispatcher:${version}

ARG extra_packages=""
RUN apt -q update && DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install ${extra_packages} net-tools

ARG server=lava-server
RUN echo "MASTER_URL=\"tcp://${server}:5556\"" >> /etc/lava-dispatcher/lava-slave
RUN echo "LOGGER_URL=\"tcp://${server}:5555\"" >> /etc/lava-dispatcher/lava-slave

ARG dispatcher_ip
RUN if [ "x$dispatcher_ip" != "x" ] ; then echo "dispatcher_ip: $dispatcher_ip >> /usr/share/lava-dispatcher/dispatcher.yaml"
RUN echo "`route -n | grep 'UG[ \t]' | awk '{print $2}'` dockerhost" >> /etc/hosts

ENTRYPOINT ["/root/entrypoint.sh"]
