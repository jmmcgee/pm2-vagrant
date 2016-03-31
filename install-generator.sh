#!/bin/bash

sudo apt-get update
#sudo apt-get -y dist-upgrade
sudo apt-get -y install linux-image-extra-virtual
sudo apt-get -y install git build-essential

# for pktgen
sudo apt-get -y install libpcap-dev liblua5.2-dev lua5.2

echo ". /vagrant/scripts/bashrc" >> ~/.bashrc
ln -sf /vagrant/scripts ~/scripts
