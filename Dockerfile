FROM nginx

ADD nginx.conf /etc/nginx.conf
ADD nginx-redirects.conf /etc/nginx-redirects.conf

RUN mkdir -p /nginx-cache/ /var/log/nginx/
