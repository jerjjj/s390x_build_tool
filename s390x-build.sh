#!/bin/bash
echo ----------------------------------------------------------------脚本仅供个人使用----------------------------------------------------------------
echo ----------------------------------------------------------------创建工作目录----------------------------------------------------------------
sudo su
mkdir s390x-build
echo ----------------------------------------------------------------安装一些依赖----------------------------------------------------------------
apt install gcc make openssl curl libssl-dev libxml2-dev libzip-dev libcurl4-openssl-dev libpng-dev libjpeg-dev \
	libwebp-dev libonig-dev libsqlite3-dev libsodium-dev libargon2-dev
apt -y install make cmake gcc g++ perl bison libaio-dev libncurses5 libncurses5-dev libnuma-dev libssl-dev
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
make install
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
make install
ln -s /opt/dotnet/dotnet /usr/local/bin
/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
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
make insatll
echo ----------------------------------------------------------------配置PHP----------------------------------------------------------------
cp php.ini-production /usr/local/etc/php.ini
mv /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf
mv /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf
echo "pid = run/php-fpm.pid" >> /usr/local/etc/php-fpm.conf
sed -i "s/listen = 127.0.0.1:9000/listen = var\/run\/php-fpm.sock\//" /usr/local/etc/php-fpm.d/www.conf
echo ----------------------------------------------------------------PHP安装完成----------------------------------------------------------------
echo ----------------------------------------------------------------开始下载MySQL源码----------------------------------------------------------------
cd ~/s390x-build/
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-boost-5.7.38.tar.gz
echo ----------------------------------------------------------------开始解压MySQL源码----------------------------------------------------------------
tar zxvf mysql-boost-5.7.38.tar.gz
mv mysql-5.7.38 mysql
echo ----------------------------------------------------------------准备编译MySQL源码----------------------------------------------------------------
groupadd mysql
useradd -r -g mysql mysql
rm -rf /opt/mysql
mkdir -p /opt/mysql/install
mkdir -p /opt/mysql/data
mkdir -p /opt/mysql/log
chown -R mysql:mysql /opt/mysql
echo ----------------------------------------------------------------编译MySQL----------------------------------------------------------------
cd mysql
cmake \
-DCMAKE_INSTALL_PREFIX=/opt/mysql/install \
-DMYSQL_UNIX_ADDR=/opt/mysql/install/mysql.sock \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_ARCHIVE_STORAGE_ENGINE=1 \
-DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
-DMYSQL_DATADIR=/opt/mysql/data \
-DMYSQL_TCP_PORT=3306 \
-DWITH_BOOST=boost
make -j2
make install
chown -R mysql:mysql /opt/mysql
chgrp -R mysql /opt/mysql
echo "PATH=$PATH:/opt/mysql/install/bin" >> /etc/profile
echo ----------------------------------------------------------------MySQL安装完成(未初始化)----------------------------------------------------------------