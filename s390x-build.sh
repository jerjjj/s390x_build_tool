#!/bin/bash
echo ----------------------------------------------------------------脚本仅供个人使用----------------------------------------------------------------
echo ----------------------------------------------------------------创建工作目录----------------------------------------------------------------
echo ----------------------------------------------------------------安装一些依赖----------------------------------------------------------------
sudo apt install gcc make openssl curl libssl-dev libxml2-dev libzip-dev libcurl4-openssl-dev libpng-dev libjpeg-dev \
	libwebp-dev libonig-dev libsqlite3-dev libsodium-dev libargon2-dev
mkdir s390x-build
echo ----------------------------------------------------------------开始拉取python源码----------------------------------------------------------------
cd s390x-build
git clone https://github.com/python/cpython.git -b main
echo ----------------------------------------------------------------开始编译python----------------------------------------------------------------
cd cpython
./configure
make
make test
echo ----------------------------------------------------------------开始安装python----------------------------------------------------------------
make install
echo ----------------------------------------------------------------python编译安装完成----------------------------------------------------------------
echo ----------------------------------------------------------------开始下载nodejs源码----------------------------------------------------------------
cd ~/s390x-build/
wget https://npmmirror.com/mirrors/node/v16.16.0/node-v16.16.0.tar.gz
echo ----------------------------------------------------------------解压nodejs源码----------------------------------------------------------------
tar zxvf node-v16.16.0.tar.gz
mv node-v16.16.0 node
rm -rf node-v16.16.0.tar.gz
echo ----------------------------------------------------------------编译nodejs源码----------------------------------------------------------------
cd node
./configure
make
echo ----------------------------------------------------------------安装nodejs----------------------------------------------------------------
sudo make install
echo ----------------------------------------------------------------nodejs安装完成----------------------------------------------------------------
echo ----------------------------------------------------------------开始下载nginx源码----------------------------------------------------------------
cd ~/s390x-build/
wget http://nginx.org/download/nginx-1.22.0.tar.gz
echo ----------------------------------------------------------------解压nginx源码----------------------------------------------------------------
tar zxvf nginx-1.22.0.tar.gz
mv nginx-1.22.0.tar.gz nginx
rm -rf nginx-1.22.0.tar.gz
echo ----------------------------------------------------------------编译nginx源码----------------------------------------------------------------
cd nginx
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-stream --with-mail=dynamic
make
echo ----------------------------------------------------------------安装nginx----------------------------------------------------------------
sudo make install
sudo ln -s /opt/dotnet/dotnet /usr/local/bin
sudo /usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
echo ----------------------------------------------------------------nginx安装完成----------------------------------------------------------------
echo ----------------------------------------------------------------开始下载PHP源码----------------------------------------------------------------
cd ~/s390x-build/
wget https://www.php.net/distributions/php-8.1.8.tar.gz
echo ----------------------------------------------------------------解压PHP源码----------------------------------------------------------------
tar zxvf php-8.1.8.tar.gz
mv php-8.1.8 php
rm -rf php-8.1.8.tar.gz
echo ----------------------------------------------------------------编译PHP----------------------------------------------------------------
cd php
./buildconf --force
./configure --enable-fpm \
	--with-fpm-user=www-data --with-fpm-group=www-data \
	--with-openssl \
	--with-zlib \
	--with-curl \
	--with-mysqli --with-pdo-mysql \
	--with-sodium \
	--with-password-argon2 \
	--with-pic \
	--without-sqlite3 \
	--without-pdo-sqlite \
	--enable-bcmath \
	--enable-ftp \
	--enable-gd --with-webp --with-jpeg \
	--enable-mbstring \
	--enable-shmop \
	--enable-sockets \
	--enable-mysqlnd \
	--disable-cgi
    
make
echo ----------------------------------------------------------------安装PHP----------------------------------------------------------------
sudo make insatll
echo ----------------------------------------------------------------配置PHP----------------------------------------------------------------
sudo cp php.ini-production /usr/local/etc/php.ini
sudo mv /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf
sudo mv /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf
sudo echo "pid = run/php-fpm.pid" >> /usr/local/etc/php-fpm.conf
sudo sed -i "s/listen = 127.0.0.1:9000/listen = var\/run\/php-fpm.sock\//" /usr/local/etc/php-fpm.d/www.conf
echo ----------------------------------------------------------------PHP安装完成----------------------------------------------------------------
