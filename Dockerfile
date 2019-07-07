FROM ubuntu:disco
ARG VERSION
RUN apt update
RUN apt install -y wget graphviz
RUN wget https://product-downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-${VERSION}-x64.bin -O /tmp/confluence.bin
RUN chmod u+x /tmp/confluence.bin
RUN /tmp/confluence.bin -q -dir /opt/confluence
RUN mkdir -p /opt/confluence/conf
RUN chown -R confluence:confluence /opt/confluence
WORKDIR /opt/confluence
COPY ./entrypoint.sh /entrypoint.sh
COPY ./scripts /opt/confluence-scripts
USER confluence
EXPOSE 8090 8091
CMD ["/entrypoint.sh"]
