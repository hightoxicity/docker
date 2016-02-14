FROM debian:jessie
MAINTAINER Tony Fouchard

ENV WK_DIR /root
ENV CREATE_WKDIR 0
ENV RM_WKDIR 0

RUN [ ${CREATE_WKDIR} -eq 1 ] && mkdir -p ${WK_DIR} || /bin/true
WORKDIR ${WK_DIR}

RUN mkdir -p /confmgt/bin
RUN mkdir -p /confmgt/attributes

RUN mkdir -p /confmgt/confd/templates
RUN mkdir -p /confmgt/confd/conf.d
COPY confd /confmgt/confd
COPY files /

RUN apt-get update && apt-get install -y wget

RUN echo 'Downloading and installing yaml2json...'
RUN wget https://github.com/bronze1man/yaml2json/blob/master/builds/linux_amd64/yaml2json?raw=true -O yaml2json
RUN chmod +x yaml2json
RUN mv yaml2json /confmgt/bin/

RUN echo 'Downloading and installing confd...'
RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.10.0/confd-0.10.0-linux-amd64
RUN mv confd-0.10.0-linux-amd64 confd
RUN chmod +x confd
RUN mv confd /confmgt/bin/

RUN echo 'Downloading and installing jq...'
RUN wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
RUN mv jq-linux64 jq
RUN chmod +x jq
RUN mv jq /confmgt/bin/

COPY bin/attr_merger.sh /confmgt/bin/attr_merger.sh
RUN chmod +x /confmgt/bin/attr_merger.sh
COPY bin/gen_conf.sh /confmgt/bin/gen_conf.sh
RUN chmod +x /confmgt/bin/gen_conf.sh
RUN mkdir /etc/confd
COPY confd.toml /etc/confd/confd.toml

RUN mkdir /confmgt/temp
COPY attributes/ /confmgt/temp/attributes/
RUN date +%s > /confmgt/temp/now
RUN mkdir /confmgt/attributes/$(cat /confmgt/temp/now)
RUN cp -r /confmgt/temp/attributes/* /confmgt/attributes/$(cat /confmgt/temp/now) || /bin/true
RUN /confmgt/bin/gen_conf.sh
RUN rm -rf /confmgt/temp

ONBUILD COPY files /
ONBUILD RUN mkdir /confmgt/temp
ONBUILD COPY attributes/ /confmgt/temp/attributes/
ONBUILD COPY confd /confmgt/confd
ONBUILD RUN date +%s > /confmgt/temp/now
ONBUILD RUN mkdir /confmgt/attributes/$(cat /confmgt/temp/now)
ONBUILD RUN cp -r /confmgt/temp/attributes/* /confmgt/attributes/$(cat /confmgt/temp/now) || /bin/true
ONBUILD RUN /confmgt/bin/gen_conf.sh
ONBUILD RUN rm -rf /confmgt/temp

RUN [ ${RM_WKDIR} -eq 1 ] && rm -rf ${WK_DIR} || /bin/true

CMD ["/confmgt/bin/gen_conf.sh"]
