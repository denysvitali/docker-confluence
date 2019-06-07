FROM ubuntu:disco
RUN apt update
RUN apt install -y wget
RUN wget https://product-downloads.atlassian.com/software/confluence/downloads/atlassian-confluence-6.15.4-x64.bin -O /tmp/confluence.bin
RUN chmod u+x /tmp/confluence.bin
RUN /tmp/confluence.bin -q -dir /opt/confluence
RUN mkdir -p /opt/confluence/conf
RUN chown -R confluence:confluence /opt/confluence
WORKDIR /opt/confluence
USER confluence
EXPOSE 8090
CMD ["/opt/confluence/bin/start-confluence.sh","-fg"]
