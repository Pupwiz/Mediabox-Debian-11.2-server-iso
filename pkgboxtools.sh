#!/bin/bash
VER=1.03
DIR=$(pwd)
rm $DIR/local_packages/boxtools*.deb
mkdir -p $DIR/boxtools_amd64/opt
cd $DIR/boxtools_amd64/opt
git clone https://github.com/mdhiggins/sickbeard_mp4_automator.git mp4auto 
git clone https://github.com/begleysm/ipwatch.git 
git clone https://github.com/mrworf/plexupdate.git 
git clone https://github.com/christgau/wsdd.git
git clone https://github.com/Pupwiz/Scripts.git bt_scripts
cd $DIR
cp $DIR/templates/boxtools/* $DIR/boxtools_amd64/ -r
dpkg-deb -b boxtools_amd64/ boxtools_$VER-amd64.deb
mv boxtools_$VER-amd64.deb ./local_packages
rm $DIR/boxtools_amd64/ -r
exit 0
