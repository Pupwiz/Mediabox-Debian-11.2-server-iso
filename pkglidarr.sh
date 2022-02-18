#!/bin/bash
rm ./local_packages/lidarr*.deb
lidarr="$(curl -sI "https://github.com/lidarr/lidarr/releases/latest" | grep -Po 'tag\/\K(v\S+)')"
mkdir -p $(pwd)/lidarr_amd64/opt
wget https://github.com/lidarr/lidarr/releases/download/$lidarr/lidarr.master.${lidarr:1}.linux-core-x64.tar.gz
tar xfz lidarr.master.${lidarr:1}.linux-core-x64.tar.gz -C $(pwd)/lidarr_amd64/opt
rm lidarr.master.${lidarr:1}.linux-core-x64.tar.gz
cp $(pwd)/templates/lidarr/* $(pwd)/lidarr_amd64/ -r
sed -i.bak "/^[[:space:]]*Version:/ s/:.*/: ${lidarr:1}/" $(pwd)/lidarr_amd64/DEBIAN/control
dpkg-deb -b lidarr_amd64/ lidarr_${lidarr:1}-amd64.deb
mv lidarr_${lidarr:1}-amd64.deb ./local_packages
rm $(pwd)/lidarr_amd64/ -r
