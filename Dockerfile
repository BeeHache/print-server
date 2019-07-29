FROM golang:1.12.6-alpine3.10

RUN apk add --no-cache git bzr gcc avahi avahi-dev cups-dev cups-libs cups-filters musl-dev
RUN go get github.com/google/cloud-print-connector/...

FROM alpine:edge 

RUN echo "http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install Packages (basic tools, cups, basic drivers, HP drivers)
RUN apk add --no-cache \
cups \
cups-libs \
cups-pdf \
cups-client \
cups-filters \
hplip 

COPY --from=0 \
/go/bin/gcp-cups-connector \
/go/bin/gcp-connector-util \
/usr/local/bin/

ADD app /app/

# Add user and disable sudo password checking
RUN adduser \
-h /var/spool/lpd  \
-s /sbin/nologin \
-D \
print \
&& adduser print lp \
&& adduser print lpadmin 

RUN echo "print:print" | chpasswd

# Configure the service's to be reachable
RUN /usr/sbin/cupsd \
&& while [ ! -f /var/run/cups/cupsd.pid ]; do sleep 1; done \
&& cupsctl --remote-admin --remote-any --share-printers \
&& kill $(cat /var/run/cups/cupsd.pid)

EXPOSE 631

CMD ["/app/run.sh"]
