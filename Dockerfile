ARG version=latest
FROM lavasoftware/lava-dispatcher:${version}
WORKDIR /opt/
RUN apt -q update || apt -q update
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install build-essential git pkg-config cmake libusb-dev libftdi-dev
RUN git clone https://github.com/96boards/96boards-uart.git
# Avoid using new libusb because of build-error
RUN cd 96boards-uart && git checkout 1d2bc993083d97b54d21ecdf72556066efce11f7
RUN cd 96boards-uart/96boardsctl/ && cmake . && make

FROM lavasoftware/lava-dispatcher:${version}

ARG extra_packages=""
RUN apt -q update || apt -q update
RUN DEBIAN_FRONTEND=noninteractive apt-get -q -y install software-properties-common libftdi1
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

# Add 96boardsctl
COPY --from=0 /opt/96boards-uart/96boardsctl/96boardsctl /usr/bin/

ARG server=lava-server
RUN echo "MASTER_URL=\"tcp://${server}:5556\"" >> /etc/lava-dispatcher/lava-slave
RUN echo "LOGGER_URL=\"tcp://${server}:5555\"" >> /etc/lava-dispatcher/lava-slave

ENTRYPOINT ["/root/entrypoint.sh"]
