FROM alpine:latest
RUN apk add --no-cache bash docker-cli
COPY docker-cleanup.sh /usr/local/bin/cleanup
RUN chmod +x /usr/local/bin/cleanup
ENTRYPOINT ["cleanup"]
