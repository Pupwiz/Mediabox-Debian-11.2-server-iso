#!/bin/bash
echo "########################################################" | wall -n
echo "## Currently debian version is working with templates ##" | wall -n
echo "## no need to build version with required modules     ##" | wall -n
echo "## remove the exit after this dialog to start builds  ##" | wall -n
echo "## and remove nginx from profiles packages and add    ##" | wall -n
echo "##  nginx21 to the packages                           ##" | wall -n
echo "########################################################" | wall -n
exit
apt install -qq libgeoip-dev libpcre3-dev zlib1g-dev checkinstall
DIR=$(pwd)
rm $DIR/local_packages/nginx.deb
nginx_version=nginx-1.21.5
mkdir -p $DIR/nginx_amd64/
BUILD_DIR=$DIR/nginx_amd64
wget https://nginx.org/download/$nginx_version.tar.gz -O - | tar -xz --strip-components=1 -C $BUILD_DIR
#wget https://www.openssl.org/source/openssl-1.1.1l.tar.gz -O - | tar -xz -C $(pwd)/build
wget https://github.com/openssl/openssl/archive/refs/tags/openssl-3.0.1.tar.gz -O - | tar -xz -C $BUILD_DIR
git clone https://github.com/aperezdc/ngx-fancyindex.git $BUILD_DIR/ngx-fancyindex
git clone git://github.com/yaoweibin/ngx_http_substitutions_filter_module.git $BUILD_DIR/ngx-subs
cd $BUILD_DIR
./configure --prefix=/etc/nginx \
    --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf \
    --modules-path=/etc/nginx/modules \
    --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=www-data --group=www-data \
    --with-openssl=$BUILD_DIR/openssl-openssl-3.0.1 \
    --with-openssl-opt=enable-tls1_3 \
    --with-http_ssl_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_v2_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-file-aio \
    --with-http_geoip_module \
    --add-module=$BUILD_DIR/ngx-fancyindex \
    --add-module=$BUILD_DIR/ngx-subs \
    --with-cc-opt='-O2 -g -pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches -m64 -mtune=generic'
make -j4
checkinstall -y --backup=no --deldoc=yes --fstrans=no --pkgname=nginx21 --pkgversion=1.21.4 --install=no
mkdir -p $BUILD_DIR/$nginx_version/DEBIAN
dpkg-deb -x *.deb $BUILD_DIR/$nginx_version/
cp $DIR/templates/nginx/* $BUILD_DIR/$nginx_version/ -R
dpkg-deb -e *.deb $BUILD_DIR/$nginx_version/DEBIAN
rm $BUILD_DIR/*amd64.deb
dpkg-deb -Z xz -b $BUILD_DIR/$nginx_version nginx_${nginx_version:6}_amd64.deb
mv $BUILD_DIR/*.deb $DIR/local_packages/
cd $DIR
rm $DIR/nginx_amd64/ -r
