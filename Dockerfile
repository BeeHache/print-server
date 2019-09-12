FROM phusion/baseimage:0.11

ARG PSUSER=print
ARG PSGROUP=print
ARG PSPASSWD=print

# Install Packages (basic tools, cups, basic drivers, HP drivers)
RUN apt-get update && apt-get install -y \
cups-daemon=2.2.7-1ubuntu2.7 \
cups-browsed=1.20.2-0ubuntu3.1 \
cups-filters=1.20.2-0ubuntu3.1 \
cups-ppdc=2.2.7-1ubuntu2.7 \
printer-driver-gutenprint=5.2.13-2 \
printer-driver-hpcups=3.17.10+repack0-5 \
printer-driver-cups-pdf=3.0.1-5 \
hplip=3.17.10+repack0-5 \
avahi-daemon=0.7-3.1ubuntu1.2 \
colord=1.3.3-2build1 \
gutenprint-locales=5.2.13-2 \
sane-utils=1.0.27-1~experimental3ubuntu2 \
google-cloud-print-connector=1.12-1 \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN adduser \
--system \
--no-create-home \
--shell /sbin/nologin \
$PSUSER \
&& addgroup $PSGROUP \
&& adduser \
--system \
--no-create-home \
--shell /sbin/nologin \
lpadmin \
&& adduser $PSUSER $PSGROUP \
&& adduser lp $PSGROUP \
&& adduser lpadmin $PSGROUP 

RUN useradd -s /usr/sbin/nologin -r -M cloud-print-connector

RUN echo $PSUSER:$PSPASSWD | chpasswd

EXPOSE 631/udp 631/tcp 161/udp 161/tcp 162/udp 162/tcp

# Expose SMB printer sharing
EXPOSE 137/udp 139/tcp 445/tcp

# Expose avahi advertisement
EXPOSE 5353/udp

RUN mkdir -p /etc/my_init.d
COPY scripts/11_dbus.sh  \
scripts/12_avahi.sh  \
scripts/13_cups-browsed.sh  \
scripts/14_cupsd.sh \
scripts/15_gcp.sh \
/etc/my_init.d/
RUN chmod +x /etc/my_init.d/*


RUN mkdir -p /etc/service/print-service
COPY scripts/run /etc/service/print-service/run
RUN chmod +x /etc/service/print-service/run

#GCP
COPY scripts/gcp /etc/init.d/
RUN chmod +x /etc/init.d/gcp
RUN mkdir -p /etc/gcp

COPY tools /tools
RUN chmod -R +x /tools

CMD ["/sbin/my_init"]
