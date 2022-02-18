#!/bin/bash
DIR=$(pwd)
rm $DIR/local_packages/radarr*.deb
mkdir -p $DIR/radarr_amd64/opt
#wget https://github.com/radarr/radarr/releases/download/$radarr/radarr.master.${radarr:1}.linux-core-x64.tar.gz
#wget --content-disposition 'https://radarr.servarr.com/v1/update/master/updatefile?os=linux&runtime=netcore&arch=x64'
wget https://github.com/Radarr/Radarr/releases/download/v4.0.4.5909/Radarr.develop.4.0.4.5909.linux-core-x64.tar.gz
tar xfz Radarr.develop.*.linux-core-x64.tar.gz -C $DIR/radarr_amd64/opt
VER=$(find ./Radarr*  -name '*.tar.gz'|grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
rm Radarr.develop.*.linux-core-x64.tar.gz
cp $DIR/templates/radarr/. $DIR/radarr_amd64/ -r
sed -i.bak "/^[[:space:]]*Version:/ s/:.*/: $VER/" $DIR/radarr_amd64/DEBIAN/control
chown -R media: $DIR/radarr_amd64/home $DIR/radarr_amd64/opt
dpkg-deb -b radarr_amd64/ radarr_$VER-amd64.deb
mv radarr_$VER-amd64.deb ./local_packages
rm $DIR/radarr_amd64/ -r

