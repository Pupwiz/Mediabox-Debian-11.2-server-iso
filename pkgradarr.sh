#!/bin/bash
DIR=$(pwd)
rm $DIR/local_packages/radarr*.deb
mkdir -p $DIR/radarr_amd64/opt
radarr=$(git ls-remote --tags https://github.com/Radarr/Radarr | sed -nE 's#.*refs/tags/(v?[0-9]+(\.[0-9]+)*)$#\1#p' | sort -Vr | head -n 1)
wget https://github.com/Radarr/Radarr/releases/download/$radarr/Radarr.master.${radarr:1}.linux-core-x64.tar.gz
tar xfz Radarr.master.*.linux-core-x64.tar.gz -C $DIR/radarr_amd64/opt
VER=$(find ./Radarr*  -name '*.tar.gz'|grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
rm Radarr.master.*.linux-core-x64.tar.gz
cp $DIR/templates/radarr/. $DIR/radarr_amd64/ -r
sed -i.bak "/^[[:space:]]*Version:/ s/:.*/: $VER/" $DIR/radarr_amd64/DEBIAN/control
chown -R media: $DIR/radarr_amd64/home $DIR/radarr_amd64/opt
dpkg-deb -b radarr_amd64/ radarr_$VER-amd64.deb
mv radarr_$VER-amd64.deb ./local_packages
rm $DIR/radarr_amd64/ -r

