FROM nginx

RUN mkdir -p /nginx-cache/ /var/log/static/ /logstash/static/

ADD nginx.conf /etc/nginx.conf
ADD nginx-redirects.conf /etc/nginx-redirects.conf
ADD logstash-nginx.conf /logstash/static/logstash-nginx.conf

VOLUME /var/log/static/
VOLUME /logstash/static/
