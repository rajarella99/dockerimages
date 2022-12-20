#OTEL CONTRIB COLLECTOR IMAGE V1#
#FROM debian:latest as builder
#FROM debian:stable-slim as builder
FROM debian:bullseye-slim as builder
USER root
LABEL maintainer="rajashaker.arella@wolterskluwer.com"
LABEL description="This Dockerfile creates Otel Collector Contrib Aggregator Agent"
RUN mkdir /telemetry
ADD download.sh /telemetry
WORKDIR /telemetry
RUN ( echo nameserver 1.1.1.1 ; echo nameserver 9.9.9.9 ; echo nameserver 8.8.8.8 ; ) >> /etc/resolv.conf
RUN apt-get update && apt-get -y install apt-utils wget telnet procps net-tools libcap2-bin 
RUN chmod +x /telemetry/download.sh
RUN /bin/sh -c /telemetry/download.sh
RUN dpkg-deb -c /telemetry/otel-contrib-collector_0.66.0_amd64.deb > /telemetry/dependency.txt
RUN dpkg --install /telemetry/otel-contrib-collector_0.66.0_amd64.deb
RUN rm -rf /telemetry/otel-contrib-collector_0.66.0_amd64.deb
COPY custom.config.yaml /usr/bin
COPY basicauth.source /usr/bin
RUN apt-get -y install net-tools telnet

FROM alpine:latest
USER root
LABEL maintainer="rajashaker.arella@wolterskluwer.com"
RUN mkdir /telemetry
RUN addgroup -g 900 otelgroup && adduser -D oteluser && adduser oteluser otelgroup
RUN chown -R oteluser:otelgroup /telemetry && chmod -R 755 /telemetry
RUN ( echo nameserver 1.1.1.1 ; echo nameserver 9.9.9.9 ; echo nameserver 8.8.8.8 ; ) >> /etc/resolv.conf
COPY --from=builder --chown=oteluser:otelgroup /usr/bin /telemetry
COPY --from=builder /lib/systemd/system/otelcol-contrib.service /telemetry
COPY --from=builder /etc/otelcol-contrib/otelcol-contrib.conf /telemetry
SHELL ["/bin/sh", "-c"]
RUN apk update && apk upgrade --no-cache \
&& apk --update --no-cache add busybox-extras
USER oteluser
EXPOSE 4317 4318 55680 55679 13133
ENTRYPOINT ["/telemetry/otelcol-contrib"]
CMD ["--config", "/telemetry/custom.config.yaml"]