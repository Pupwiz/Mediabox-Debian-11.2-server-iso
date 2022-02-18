#!/bin/bash
DIR=$(pwd)
rm $DIR/local_packages/readarr*.deb
lastreadarr() { git ls-remote --tags "$1" | cut -d/ -f3- | tail -n1; }
readarr=$(lastreadarr https://github.com/readarr/readarr.git)
mkdir -p $DIR/readarr_amd64/opt
wget --content-disposition 'http://readarr.servarr.com/v1/update/nightly/updatefile?os=linux&runtime=netcore&arch=x64'
VER=$(find ./Readarr*  -name '*.tar.gz'|grep -Eo '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
tar xfz Readarr.develop.*.linux-core-x64.tar.gz -C $DIR/readarr_amd64/opt
rm Readarr.develop.*.linux-core-x64.tar.gz
cp $DIR/templates/readarr/. $DIR/readarr_amd64/ -r
sed -i.bak "/^[[:space:]]*Version:/ s/:.*/: $VER/" $DIR/readarr_amd64/DEBIAN/control
chown -R media: $DIR/readarr_amd64/home $DIR/readarr_amd64/usr
dpkg-deb -b readarr_amd64/ readarr_$VER-amd64.deb
mv readarr_$VER-amd64.deb ./local_packages
rm $DIR/readarr_amd64/ -r
