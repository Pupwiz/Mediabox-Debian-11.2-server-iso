#!/bin/bash
apt-get build-dep transmission
apt -qq install -y cmake apt install libssl-dev zlib1g-dev build-essential automake autoconf libtool pkg-config intltool libcurl4-openssl-dev libcurl4-gnutls-dev libglib2.0-dev libevent-dev libminiupnpc-dev libnatpmp-dev
#wget http://ftp.ca.debian.org/debian/pool/main/libi/libindicator/libindicator3-7_0.5.0-3+b1_amd64.deb
#wget http://ftp.ca.debian.org/debian/pool/main/liba/libappindicator/libappindicator3-1_0.4.92-7_amd64.deb
#dpkg -i libindicator3-7_0.5.0-3+b1_amd64.deb
#dpkg -i  libappindicator3-1_0.4.92-7_amd64.deb

DIR=$(pwd)
rm $DIR/local_packages/transmission*.deb
lasttransmission() { git ls-remote --tags "$1" | cut -d/ -f3- | tail -n1; }
transmission=$(lasttransmission https://github.com/transmission/transmission.git)
#git clone https://github.com/transmission/transmission transmission_amd64
mkdir -p $DIR/transmission_amd64
cd transmission_amd64
wget https://github.com/transmission/transmission-releases/raw/master/transmission-$transmission.tar.xz
tar -xf transmission-$transmission.tar.xz --strip-components=1
./configure --enable-utp --enable-daemon --enable-nls --enable-cli --enable-daemon --enable-external-natpmp --with-systemd --without-gtk
#git submodule update --init
#mkdir build
#cd build
# Use -DCMAKE_BUILD_TYPE=RelWithDebInfo to build optimized binary.
#cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo ..
make -j4
#sudo make install
checkinstall -y --backup=no --deldoc=yes --fstrans=no --pkgname=transmission3.0 --pkgversion=1.0 --install=no
mkdir -p $transmission/DEBIAN
dpkg-deb -x *.deb $transmission/
cp $DIR/templates/transmission/* $transmission/ -R
dpkg-deb -e *.deb $transmission/DEBIAN
dpkg-deb -Z xz -b $transmission/ transmission_$transmission-amd64.deb
mv transmission_$transmission-amd64.deb $DIR/local_packages/
rm $DIR/transmission_amd64/ -r
exit 0
