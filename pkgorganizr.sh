#!/bin/bash
DIR=$(pwd)
rm $DIR/local_packages/organizr*.deb
#lastorganizr() { git ls-remote --tags "$1" | cut -d/ -f3- | tail -n1; }
#orgnizr=$(lastorganiz https://github.com/causefx/Organizr.git)
mkdir -p $DIR/organizr_amd64/
#wget -qO- http://apt.sonarr.tv/debian/pool/main/s/sonarr/sonarr_${sonarr:1:-3}_all.deb
#wget https://github.com/Sonarr/Sonarr/archive/refs/tags/${sonarr:0:-3}.tar.gz
cp $DIR/templates/organizr/. $DIR/organizr_amd64/ -r
#sed -i.bak "/^[[:space:]]*Version:/ s/:.*/: ${sonarr:1:-3}/" $DIR/sonarr_amd64/DEBIAN/control 
cd $DIR/organizr_amd64/var/www/html/
git clone https://github.com/causefx/Organizr.git .
cp $DIR/templates/orgconfigdb/orgdb.db $DIR/organizr_amd64/var/www/html/
cp $DIR/templates/orgconfigdb/*.php $DIR/organizr_amd64/var/www/html/api/config
cp $DIR/templates/orgconfigdb/cloudcmd.png $DIR/organizr_amd64/var/www/html/plugins/images/tabs/
cd $DIR
chown -R www-data: $DIR/organizr_amd64/var
dpkg-deb -b organizr_amd64/ organizr_2.01-amd64.deb
mv organizr_2.01-amd64.deb $DIR/local_packages 
rm organizr_amd64/ -r
exit 0
