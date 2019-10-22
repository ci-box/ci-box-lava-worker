ARG version=latest
FROM lavasoftware/lava-dispatcher:${version}

ARG extra_packages=""
RUN apt -q update || apt -q update
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install software-properties-common
RUN apt-add-repository non-free
RUN apt -q update || apt -q update
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install ${extra_packages} net-tools snmp snmp-mibs-downloader
RUN download-mibs

# Add MIBs
RUN mkdir -p /usr/share/snmp/mibs/
ADD powernet428.mib /usr/share/snmp/mibs/

# Add lab scripts
RUN mkdir -p /usr/local/lab-scripts/
ADD https://git.linaro.org/lava/lava-lab.git/plain/shared/lab-scripts/snmp_pdu_control /usr/local/lab-scripts/
RUN chmod a+x /usr/local/lab-scripts/snmp_pdu_control
ADD https://git.linaro.org/lava/lava-lab.git/plain/shared/lab-scripts/eth008_control /usr/local/lab-scripts/
RUN chmod a+x /usr/local/lab-scripts/eth008_control

ARG server=lava-server
RUN echo "MASTER_URL=\"tcp://${server}:5556\"" >> /etc/lava-dispatcher/lava-slave
RUN echo "LOGGER_URL=\"tcp://${server}:5555\"" >> /etc/lava-dispatcher/lava-slave

ENTRYPOINT ["/root/entrypoint.sh"]
