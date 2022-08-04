#!/bin/bash
echo ----------------------------------------------------------------脚本仅供个人使用----------------------------------------------------------------
echo 作者: jerjjj@github
echo 版本: 0.4
echo 发布位置:https://github.com/jerjjj/s390x_build_tool
echo 适用版本:理论上所有ubuntu适用,但其实也只有s390x架构的计算机需要这么麻烦
echo 注意事项:请在su模式下执行本脚本,不要用sudo命令
echo python编译版本:3.12
echo nodejs编译版本:16.16.0
echo nginx编译版本:1.22.0
echo php编译版本:8.1.8
echo mysql编译版本:5.7.38
echo ---------------------------------------------------------------------------------------------------------------------------------------- 
#定义一些变量，分别表示编译成功，编译失败，总编译数量
BS=0
BF=0
BA=5
echo ----------------------------------------------------------------创建工作目录----------------------------------------------------------------
mkdir s390x-build
echo ----------------------------------------------------------------安装一些依赖----------------------------------------------------------------
apt install gcc make openssl curl libssl-dev libxml2-dev libzip-dev libcurl4-openssl-dev libpng-dev libjpeg-dev \
	libwebp-dev libonig-dev libsqlite3-dev libsodium-dev libargon2-dev
apt -y install make cmake gcc g++ perl bison libaio-dev libncurses5 libncurses5-dev libnuma-dev libssl-dev
if [ $? -ne 0 ];then
  echo 请在su模式下执行本脚本(可用sudo su命令)
  rm -rf s390x-build
  exit
fi
echo ----------------------------------------------------------------开始拉取python源码----------------------------------------------------------------
cd s390x-build
git clone https://github.com/python/cpython.git -b main
if [ $? -ne 0 ];then
  echo 源码拉取失败
fi
echo ----------------------------------------------------------------开始编译python----------------------------------------------------------------
cd cpython
./configure
make
make test
if [ $? -ne 0 ];then
  echo 编译失败
fi
echo ----------------------------------------------------------------开始安装python----------------------------------------------------------------
make install
if [ $? -ne 0 ];then
  echo python安装失败
  ((BF++))
else
  echo ----------------------------------------------------------------python编译安装完成----------------------------------------------------------------
  ((BS++))
fi
echo ----------------------------------------------------------------开始下载nodejs源码----------------------------------------------------------------
cd ~/s390x-build/
wget https://npmmirror.com/mirrors/node/v16.16.0/node-v16.16.0.tar.gz
if [ $? -ne 0 ];then
  echo nodejs源码拉取失败
fi
echo ----------------------------------------------------------------解压nodejs源码----------------------------------------------------------------
tar zxvf node-v16.16.0.tar.gz
mv node-v16.16.0 node
if [ $? -ne 0 ];then
  echo nodejs源码解压失败
fi
rm -rf node-v16.16.0.tar.gz
echo ----------------------------------------------------------------编译nodejs源码----------------------------------------------------------------
cd node
./configure
make
if [ $? -ne 0 ];then
  echo nodejs编译失败
fi
echo ----------------------------------------------------------------安装nodejs----------------------------------------------------------------
make install
if [ $? -ne 0 ];then
  echo nodejs安装失败
  ((BF++))
else
  echo ----------------------------------------------------------------nodejs安装完成----------------------------------------------------------------
  ((BS++))
fi
echo ----------------------------------------------------------------开始下载nginx源码----------------------------------------------------------------
cd ~/s390x-build/
wget http://nginx.org/download/nginx-1.22.0.tar.gz
if [ $? -ne 0 ];then
  echo nginx源码下载失败
fi
echo ----------------------------------------------------------------解压nginx源码----------------------------------------------------------------
tar zxvf nginx-1.22.0.tar.gz
mv nginx-1.22.0.tar.gz nginx
if [ $? -ne 0 ];then
  echo nginx源码解压失败
fi
rm -rf nginx-1.22.0.tar.gz
echo ----------------------------------------------------------------编译nginx源码----------------------------------------------------------------
cd nginx
./configure --prefix=/usr/local/nginx --with-http_ssl_module --with-stream --with-mail=dynamic
make
if [ $? -ne 0 ];then
  echo nginx编译失败
fi
echo ----------------------------------------------------------------安装nginx----------------------------------------------------------------
make install
ln -s /opt/dotnet/dotnet /usr/local/bin
/usr/local/nginx/sbin/nginx -c /usr/local/nginx/conf/nginx.conf
if [ $? -ne 0 ];then
  echo nginx 安装失败
  ((BF++))
else
  echo ----------------------------------------------------------------nginx安装完成----------------------------------------------------------------
  ((BS++))
fi
echo ----------------------------------------------------------------开始下载PHP源码----------------------------------------------------------------
cd ~/s390x-build/
wget https://www.php.net/distributions/php-8.1.8.tar.gz
if [ $? -ne 0 ];then
  echo php源码下载失败
fi
echo ----------------------------------------------------------------解压PHP源码----------------------------------------------------------------
tar zxvf php-8.1.8.tar.gz
mv php-8.1.8 php
if [ $? -ne 0 ];then
  echo php源码解压失败
fi
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
if [ $? -ne 0 ];then
  echo php编译失败
fi
echo ----------------------------------------------------------------安装PHP----------------------------------------------------------------
make insatll
if [ $? -ne 0 ];then
  echo php安装失败
  ((BF++))
else
  echo ----------------------------------------------------------------PHP安装完成----------------------------------------------------------------
  ((BS++))
fi
cp php.ini-production /usr/local/etc/php.ini
mv /usr/local/etc/php-fpm.conf.default /usr/local/etc/php-fpm.conf
mv /usr/local/etc/php-fpm.d/www.conf.default /usr/local/etc/php-fpm.d/www.conf
echo "pid = run/php-fpm.pid" >> /usr/local/etc/php-fpm.conf
sed -i "s/listen = 127.0.0.1:9000/listen = var\/run\/php-fpm.sock\//" /usr/local/etc/php-fpm.d/www.conf
echo ----------------------------------------------------------------开始下载MySQL源码----------------------------------------------------------------
cd ~/s390x-build/
wget https://downloads.mysql.com/archives/get/p/23/file/mysql-boost-5.7.38.tar.gz
if [ $? -ne 0 ];then
  echo MySQL源码下载失败
fi
echo ----------------------------------------------------------------开始解压MySQL源码----------------------------------------------------------------
tar zxvf mysql-boost-5.7.38.tar.gz
if [ $? -ne 0 ];then
  echo MySQL源码解压失败
fi
mv mysql-5.7.38 mysql
rm -rf mysql-boost-5.7.38.tar.gz
echo ----------------------------------------------------------------准备编译MySQL源码----------------------------------------------------------------
groupadd mysql
useradd -r -g mysql mysql
rm -rf /opt/mysql
mkdir -p /opt/mysql/install
mkdir -p /opt/mysql/data
mkdir -p /opt/mysql/log
chown -R mysql:mysql /opt/mysql
echo ----------------------------------------------------------------编译并安装MySQL----------------------------------------------------------------
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
make -j2 #数字代表需要多少核心编译，理论上核心越多，编译越快
make install
chown -R mysql:mysql /opt/mysql
chgrp -R mysql /opt/mysql
echo "PATH=$PATH:/opt/mysql/install/bin" >> /etc/profile
if [ $? -ne 0 ];then
  echo MySQL安装失败
  ((BF++))
else
  echo ----------------------------------------------------------------MySQL安装完成(未初始化)----------------------------------------------------------------
  ((BS++))
fi
echo ----------------------------------------------------------------清理工作目录----------------------------------------------------------------
cd
rm -rf s390x-build
echo ----------------------------------------------------------------脚本运行完成，计划编译$BA,编译成功$BS,编译失败$BF----------------------------------------------------------------