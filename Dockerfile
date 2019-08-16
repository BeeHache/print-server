FROM debian:stable

# Install Packages (basic tools, cups, basic drivers, HP drivers)
RUN apt-get update && apt-get install -y \
inetutils-syslogd \
dbus \
cups-server-common \
cups-pdf \
python3-cupshelpers \
avahi-discover \
libnss-mdns \
avahi-autoipd \
hplip \
printer-driver-gutenprint \
&& rm -rf /var/lib/apt/lists/*


#COPY --from=beehache/gcp \
#/go/bin/gcp-cups-connector \
#/go/bin/gcp-connector-util \
#/app/

ADD app /app/

RUN adduser \
--system \
--no-create-home \
--shell /sbin/nologin \
print \
&& addgroup print \
&& addgroup print print \
&& adduser print lp \
&& adduser print lpadmin 

RUN echo "print:print" | chpasswd

# Configure the service's to be reachable
#RUN /usr/sbin/cupsd \
#&& while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
#&& cupsctl --remote-admin --remote-any --share-printers \
#&& kill $(cat /var/run/cups/cupsd.pid)

EXPOSE 631/udp 631/tcp 161/udp 161/tcp 162/udp 162/tcp

# Expose SMB printer sharing
EXPOSE 137/udp 139/tcp 445/tcp

# Expose avahi advertisement
EXPOSE 5353/udp

WORKDIR /app/

CMD ["/bin/sh", "-c", "/app/run.sh > /app/init-log 2>&1"]
