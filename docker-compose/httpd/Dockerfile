FROM alpine:3.9

RUN apk add apache2 php7-apache2 php7-mongodb --update-cache --no-cache            

RUN ln -sf /dev/stdout /var/log/apache2/access.log && \
    ln -sf /dev/stderr /var/log/apache2/error.log && \
    mkdir -p /run/apache2/ && \
    sed -i 's/#LoadModule rewrite_module/LoadModule rewrite_module/g' /etc/apache2/httpd.conf && \
    sed -i 's/AllowOverride None/AllowOverride All/1' /etc/apache2/httpd.conf

EXPOSE 80
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

COPY ["html/", "/var/www/localhost/htdocs/"]
ENV MONGO_CS="mongodb://localhost:27017"
