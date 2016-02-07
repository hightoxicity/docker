FROM base:latest
#FROM debian:jessie
MAINTAINER Tony Fouchard

ENV WK_DIR /root/nginx
ENV CREATE_WKDIR 1
ENV RM_WKDIR 1
ENV OPENSSL_TARGZ_LINK https://www.openssl.org/source/openssl-1.0.2f.tar.gz
ENV LUAJIT_TARGZ_LINK http://luajit.org/download/LuaJIT-2.0.1.tar.gz
ENV NGXDEVELKIT_TARGZ_LINK https://github.com/simpl/ngx_devel_kit/archive/v0.2.19.tar.gz
ENV LUANGINXMODULE_TARGZ_LINK https://github.com/openresty/lua-nginx-module/archive/v0.10.0.tar.gz
ENV NGINX_TARGZ_LINK http://nginx.org/download/nginx-1.9.10.tar.gz
ENV NGINX_USER nginx
ENV NGINX_GROUP nginx

RUN [ ${CREATE_WKDIR} -eq 1 ] && mkdir -p ${WK_DIR} || /bin/true
WORKDIR ${WK_DIR}

RUN groupadd ${NGINX_GROUP}
RUN groupmod -g 400 ${NGINX_GROUP}
RUN adduser --system --no-create-home --shell /bin/false --gid 400 --disabled-login ${NGINX_USER}
RUN usermod -u 400 ${NGINX_USER}

RUN apt-get update && \
  apt-get install -y build-essential wget

RUN echo 'Downloading OpenSSL...'
RUN wget ${OPENSSL_TARGZ_LINK}
RUN tar xvzf $(echo "${OPENSSL_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)/\1/g')

RUN echo 'Downloading and building LuaJIT 2.1...'
RUN wget ${LUAJIT_TARGZ_LINK}
RUN tar xvzf $(echo "${LUAJIT_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)/\1/g')
RUN cd ${WK_DIR}/$(echo "${LUAJIT_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)\.tar\.gz/\1/g') && make && make install

RUN echo 'Downloading ngx_devel_kit...'
RUN mkdir ${WK_DIR}/ngx_devel_kit
RUN cd ${WK_DIR}/ngx_devel_kit && wget ${NGXDEVELKIT_TARGZ_LINK}
RUN cd ${WK_DIR}/ngx_devel_kit && tar xvzf $(echo "${NGXDEVELKIT_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)/\1/g')

RUN echo 'Downloading lua-nginx-module...'
RUN mkdir ${WK_DIR}/lua-nginx-module
RUN cd ${WK_DIR}/lua-nginx-module && wget ${LUANGINXMODULE_TARGZ_LINK}
RUN cd ${WK_DIR}/lua-nginx-module && tar xvzf $(echo "${LUANGINXMODULE_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)/\1/g')

RUN apt-get install -y zlib1g-dev libpcre3-dev libperl-dev

RUN echo 'Downloading and building NGINX...'
RUN cd ${WK_DIR} && wget $NGINX_TARGZ_LINK
RUN tar xvzf $(echo "${NGINX_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)/\1/g')

RUN cd ${WK_DIR}/$(echo "${NGINX_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)\.tar\.gz/\1/g') && ./configure \
  --user=${NGINX_USER} \
  --group=${NGINX_GROUP} \
  --with-http_ssl_module \
  --with-openssl=${WK_DIR}/$(echo "${OPENSSL_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)\.tar\.gz/\1/g') \
  --with-http_gunzip_module \
  --with-http_v2_module \
  --with-http_perl_module \
  --with-http_stub_status_module \
  --with-ld-opt="-Wl,-rpath,${WK_DIR}/$(echo "${LUAJIT_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)\.tar\.gz/\1/g')" \
  --add-module=$(ls -d ${WK_DIR}/ngx_devel_kit/*/) \
  --add-module=$(ls -d ${WK_DIR}/lua-nginx-module/*/) \
  --prefix=/etc/nginx \
  --sbin-path=/usr/sbin/nginx \
  --conf-path=/etc/nginx/nginx.conf \
  --pid-path=/run/nginx.pid \
  --error-log-path=/var/log/nginx/error.log \
  --http-log-path=/var/log/nginx/access.log

RUN cd ${WK_DIR}/$(echo "${NGINX_TARGZ_LINK}" | sed -e 's/^.*\/\(.*\)\.tar\.gz/\1/g') && make -j2 && make install

RUN apt-get remove -y build-essential
RUN [ ${RM_WKDIR} -eq 1 ] && rm -rf ${WK_DIR} || /bin/true

CMD ["/confmgt/bin/gen_conf.sh"]
