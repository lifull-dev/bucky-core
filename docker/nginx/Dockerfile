FROM nginx:1.13
RUN rm -f /etc/nginx/conf.d/*
RUN rm -f /usr/share/nginx/html/*

COPY ./public /app/public
ADD ./nginx.conf /etc/nginx/nginx.conf
CMD /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
