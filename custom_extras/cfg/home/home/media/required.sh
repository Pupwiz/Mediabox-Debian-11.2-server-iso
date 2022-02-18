#!/bin/bash
echo "Installer adding final programs"  | wall -n
apt -qq install -y dialog
sudo DEBIAN_FRONTEND=noninteractive apt -qq install -y plexmediaserver || exit 1
echo "Plex Media Server install completed..!"  | wall -n
systemctl stop plexmediaserver
systemctl stop netdata
systemctl stop transmission-daemon
systemclt stop sonarr
systemctl stop radarr
systemctl stop prowlarr
tar xf /var/lib/plexmediaserver/Library.tar.gz
sudo usermod -a -G media plex
sudo usermod -a -G plex media
apt -qq install -y nodejs || exit 1
pip install bottle || exit 1
pip install -r /opt/mp4auto/setup/requirements.txt || exit 1
chown media: -R /opt/mp4auto || exit 1
echo "Installing Cloudcmd with Gritty..!"  | wall -n
sudo -H -E npm config set user 0
sudo -H -E npm config set unsafe-perm true
sudo -H -E npm install cloudcmd -g
sudo -H -E npm install gritty -g
cat >"/etc/systemd/system/cloudcmd.service" <<EOL
[Unit]
        Description=Cloud Commander
        [Service]
        TimeoutStartSec=0
        Restart=always
        User=root
        WorkingDirectory=/home/media
        ExecStart=/usr/bin/cloudcmd
        [Install]
        WantedBy=multi-user.target
EOL
echo "Starting Cloudcmd..!"  | wall -n
# Reload systemd daemon
systemctl daemon-reload
# Enable the service for following restarts
systemctl enable cloudcmd.service
# Run the service
systemctl start cloudcmd.service   
# stop openvpn until user supplied info 
echo "Cloudcmd install completed..!"  | wall -n
/bin/bash /home/media/update_arr.database || exit 1
echo "Updating database Arr programs completed..!"  | wall -n
echo "System will reboot one last time for final updates install..!"  | wall -n
echo "Updates and software not required to make the system run will "  | wall -n
echo "now be removed please wait for the reboot. Dont force the system off..!"  | wall -n
#sudo apt -qq upgrade -y
#sudo DEBIAN_FRONTEND=noninteractive apt-get -qq remove aspell aspell-en debian-faq debian-faq-de debian-faq-fr debian-faq-it debian-faq-zh-cn eject doc-debian fdutils foomatic-filters hplip iamerican ibritish ispell laptop-detect vim-common vim-tiny wamerican reportbug whiptail
apt-get -qq autoremove
rm /etc/issue
cat > /etc/issue << EOF
Hostname \n  
Date: \d
IP4 address: \4
Login User: \U
\t
Welcome!
EOF
##/bin/bash /home/media/bleachbit.sh
rm /etc/systemd/system/getty@.service.d/override.conf
rm -- "$0"
init 6
exit 0
