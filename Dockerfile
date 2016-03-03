FROM zooniverse/nginx:alpine

RUN mkdir -p /nginx-cache/ /var/log/static/ /logstash/static/ && \
    touch /etc/nginx-deny.conf

ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx-redirects.conf /etc/nginx/redirects.conf
ADD nginx-proxy.conf /etc/nginx/proxy.conf
ADD logstash-nginx.conf /logstash/static/logstash-nginx.conf
ADD sites/ /etc/nginx/sites/

VOLUME /var/log/static/
VOLUME /logstash/static/
