# Snort in Docker
FROM ubuntu:18.04

MAINTAINER David Bridges

RUN apt-get update && \
    apt-get install -y \
        #python-setuptools \
        #python-pip \
        #python-dev \
        wget \
        build-essential \
        bison \
        flex \
        libpcap-dev \
        libpcre3-dev \
        libdumbnet-dev \
    	liblzma-dev \ 
        zlib1g-dev \
        iptables-dev \
        libnetfilter-queue1 \
        tcpdump \
        unzip \
        vim 

# Define working directory.
WORKDIR /opt

ENV DAQ_VERSION 2.0.6
RUN wget https://www.snort.org/downloads/archive/snort/daq-${DAQ_VERSION}.tar.gz \
    && tar xvfz daq-${DAQ_VERSION}.tar.gz \
    && cd daq-${DAQ_VERSION} \
    && ./configure; make; make install

ENV SNORT_VERSION 2.9.8.2
RUN wget https://www.snort.org/downloads/archive/snort/snort-${SNORT_VERSION}.tar.gz \
    && tar xvfz snort-${SNORT_VERSION}.tar.gz \
    && cd snort-${SNORT_VERSION} \
    && ./configure; make; make install

RUN ldconfig

RUN wget --no-check-certificate \
    https://github.com/dvbridges/docker-snort/archive/master.zip \
    && unzip master.zip

ENV SNORT_RULES_SNAPSHOT 2983 
ENV RULE_PATH docker-snort-master/snortrules-snapshot-${SNORT_RULES_SNAPSHOT}

# ADD mysnortrules /opt
RUN mkdir -p /var/log/snort && \
    mkdir -p /usr/local/lib/snort_dynamicrules && \
    mkdir -p /etc/snort && \
    mkdir -p /etc/snort/preproc_rules && \
    mkdir -p /etc/snort/so_rules && \
    # snapshot2983 rules
    cp -r ${RULE_PATH}/rules /etc/snort/rules && \
    cp -r ${RULE_PATH}/preproc_rules/* /etc/snort/preproc_rules && \
    cp -r ${RULE_PATH}/so_rules/* /etc/snort/so_rules && \
    cp -r ${RULE_PATH}/etc /etc/snort/etc && \
    # touch /etc/snort/rules/local.rules && \
    touch /etc/snort/rules/white_list.rules /etc/snort/rules/black_list.rules

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    /opt/daq-${DAQ_VERSION}.tar.gz \  /opt/snort-${SNORT_VERSION}.tar.gz \
    /opt/master.zip /opt/docker-snort-master  


ENV NETWORK_INTERFACE eth0
# Validate an installation
# snort -T -i eth0 -c /etc/snort/etc/snort.conf
CMD ["snort", "-T", "-i", "echo ${NETWORK_INTERFACE}", "-c", "/etc/snort/etc/snort.conf"]
