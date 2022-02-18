#!/bin/bash
stat -c %s 
DIR=$(pwd)
rm $DIR/local_packages/prowlarr*.deb
prowlarr=$(git ls-remote --tags https://github.com/Prowlarr/Prowlarr | sed -nE 's#.*refs/tags/(v?[0-9]+(\.[0-9]+)*)$#\1#p' | sort -Vr | head -n 1)
mkdir -p $DIR/prowlarr_amd64/opt
wget https://github.com/Prowlarr/Prowlarr/releases/download/$prowlarr/Prowlarr.develop.${prowlarr#?}.linux-core-x64.tar.gz
tar xfz Prowlarr.develop.${prowlarr#?}.linux-core-x64.tar.gz -C $DIR/prowlarr_amd64/opt
rm Prowlarr.develop.${prowlarr#?}.linux-core-x64.tar.gz
cp $DIR/templates/prowlarr/. $DIR/prowlarr_amd64/ -r
SIZE=$(stat -c%s $DIR/prowlarr_amd64/)
chown -R media: $DIR/prowlarr_amd64/usr $DIR/prowlarr_amd64/home
sed -i.bak "/^[[:space:]]*Version:/ s/:.*/: ${prowlarr#?}/" $DIR/prowlarr_amd64/DEBIAN/control
dpkg-deb -b prowlarr_amd64/ prowlarr_${prowlarr#?}-amd64.deb
mv prowlarr_${prowlarr#?}-amd64.deb $DIR/local_packages 
rm prowlarr_amd64/ -r
