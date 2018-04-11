FROM python3/luisito666 

MAINTAINER Luis Penagos <produccion8@softpymes.com.co>

ENV FLASK_APP app_idp.py 

RUN apk update && apk upgrade \ 
	&& apk add nginx \
	&& mkdir -p /etc/nginx/certs \
	&& mkdir -p /var/run/nginx/ \
	&& cd /var/run/nginx \ && touch nginx.pid \ 
	&& apk add xmlsec-dev

ADD identityProvider /var/www/html/identityProvider

COPY certificados/mykey.pem /var/www/html/identityProvider/certificates
COPY certificados/mycert.pem /var/www/html/identityProvider/certificates

COPY certificados/mykey.pem /etc/nginx/certs
COPY certificados/mycert_nginx.pem /etc/nginx/certs

ADD octopus.conf /etc/nginx/conf.d

WORKDIR /var/www/html/identityProvider/

RUN set -ex \
	&& apk add --no-cache --virtual .build-deps  bzip2-dev \
                                              coreutils \
                                              dpkg-dev \
                                              dpkg \
                                              expat-dev \
                                              gcc\
                                              gdbm-dev \
                                              libc-dev \
                                              libffi-dev \
                                              linux-headers \
                                              make \
                                              ncurses-dev \
                                              openssl \
                                              openssl-dev \
                                              pax-utils \
                                              readline-dev \
                                              sqlite-dev \
                                              tcl-dev \
                                              tk \
                                              tk-dev \
                                              xz-dev \
                                              zlib-dev \
					      libffi \
					      libffi-dev \
\
&& pip install -r /var/www/html/identityProvider/requirements.txt \
\
&& apk del .build-deps \
&& pip install gunicorn

CMD nginx ; gunicorn app_idp:app --bind 127.0.0.1:5001

