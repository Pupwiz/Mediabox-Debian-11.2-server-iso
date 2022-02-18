#!/bin/bash
DIR=$(pwd)
sonarr=3.0.6.1457
#rm $DIR/local_packages/sonarr*.deb
#lastsonarr() { git ls-remote --tags "$1" | cut -d/ -f3- | tail -n1; }
#sonarr=$(lastsonarr https://github.com/sonarr/sonarr.git)
mkdir -p $DIR/sonarr_amd64/opt/Sonarr 
mkdir -p $DIR/sonarr_amd64/tmp
cd $DIR/sonarr_amd64/tmp
wget "https://apt.sonarr.tv/debian/pool/main/s/sonarr/sonarr_${sonarr}_all.deb"
ar x sonarr*.deb
rm *.deb control.*
tar xvf data.tar.xz  ./usr/lib/sonarr/bin/
mv ./usr/lib/sonarr/bin/* $DIR/sonarr_amd64/opt/Sonarr
cd $DIR
rm  $DIR/sonarr_amd64/tmp -r
#wget -qO- http://apt.sonarr.tv/debian/pool/main/s/sonarr/sonarr_${sonarr:1:-3}_all.deb
#wget https://github.com/Sonarr/Sonarr/archive/refs/tags/${sonarr:0:-3}.tar.gz
#curl -L "https://services.sonarr.tv/v1/download/main/latest?version=3&os=linux" | tar xfz - -C $DIR/sonarr_amd64/opt
cp $DIR/templates/sonarr/. $DIR/sonarr_amd64/ -r
sed -i.bak "/^[[:space:]]*Version:/ s/:.*/: ${sonarr}/" $DIR/sonarr_amd64/DEBIAN/control 
chown -R media: $DIR/sonarr_amd64/home $DIR/sonarr_amd64/opt
dpkg-deb -b sonarr_amd64/ sonarr_${sonarr}-amd64.deb
mv sonarr_${sonarr}-amd64.deb $DIR/local_packages 
rm sonarr_amd64/ -r
exit 0
