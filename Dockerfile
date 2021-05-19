FROM zooniverse/nginx

RUN mkdir -p /nginx-cache/  &&  touch /etc/nginx-deny.conf

ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx-redirects.conf /etc/nginx/redirects.conf
ADD nginx-proxy.conf /etc/nginx/proxy.conf
ADD nginx-proxy-headers.conf /etc/nginx/proxy-headers.conf
ADD nginx-az-proxy-headers.conf /etc/nginx/az-proxy-headers.conf
ADD nginx-api-proxy.conf /etc/nginx/api-proxy.conf
ADD sites/ /etc/nginx/sites/
