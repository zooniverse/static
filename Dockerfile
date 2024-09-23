FROM zooniverse/nginx:1.20

RUN mkdir -p /nginx-cache/  &&  touch /etc/nginx-deny.conf

ADD nginx.conf /etc/nginx/nginx.conf
ADD nginx-redirects.conf /etc/nginx/redirects.conf
ADD nginx-proxy.conf /etc/nginx/proxy.conf
ADD nginx-proxy-security-headers.conf /etc/nginx/proxy-security-headers.conf
ADD nginx-project-redirects.conf /etc/nginx/project-redirects.conf
ADD nginx-pfe-redirects.conf /etc/nginx/pfe-redirects.conf
ADD nginx-pfe-staging-redirects.conf /etc/nginx/pfe-staging-redirects.conf
ADD nginx-s3-proxy-headers.conf /etc/nginx/s3-proxy-headers.conf
ADD nginx-az-proxy-headers.conf /etc/nginx/az-proxy-headers.conf
ADD sites/ /etc/nginx/sites/
