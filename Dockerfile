FROM zooniverse/nginx

RUN mkdir -p /nginx-cache/  &&  touch /etc/nginx-deny.conf

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/redirects.conf /etc/nginx/redirects.conf
ADD conf/proxy.conf /etc/nginx/proxy.conf
ADD conf/proxy-headers.conf /etc/nginx/proxy-headers.conf
ADD conf/az-proxy-headers.conf /etc/nginx/az-proxy-headers.conf
ADD sites/ /etc/nginx/sites/
