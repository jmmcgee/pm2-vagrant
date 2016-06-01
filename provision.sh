#!/bin/bash

### Misc. Configurations
echo "STARTING provision.sh" $@
if [ ! -f /vagrant/scripts/bashrc ]; then
	echo "ERROR bashrc not found"
	exit -1
fi

function install_dependencies
{
	sudo apt-get update
	#sudo apt-get -y dist-upgrade
	sudo apt-get -y install linux-image-extra-virtual
	sudo apt-get -y install git build-essential gdb
	sudo apt-get -y install autoconf automake m4

	# for pktgen
	sudo apt-get -y install libpcap-dev liblua5.2-dev lua5.2

	# for mtcp
	#sudo apt-get -y install libps libnuma-dev libpthread librt

	# for pm2
	sudo apt-get -y install libopenmpi-dev hwloc doxygen expat libexpat-dev gfortran

	echo ". /vagrant/scripts/bashrc" >> ~/.bashrc
	echo ". /vagrant/provision.sh" >> ~/.bashrc
	ln -sf /vagrant/scripts ~/scripts
}

function add_hosts
{
	echo "10.0.1.12 generator" | sudo tee -a /etc/hosts
	echo "10.0.1.22 receiver" | sudo tee -a /etc/hosts
	echo "10.0.1.23 receiver" | sudo tee -a /etc/hosts
	echo "10.0.1.24 receiver" | sudo tee -a  /etc/hosts
}

function export_pubkey
{
	cd $HOME
	ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
	cat .ssh/authorized_keys .ssh/id_rsa.pub >> /vagrant/authorized_keys
	#sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/g' 
}

function import_pubkey
{
	cd $HOME
	cp /vagrant/authorized_keys .ssh/authorized_keys
}


### DPDK Stuff

function compile_dpdk
{
	export RTE_TARGET="x86_64-native-linuxapp-gcc" /etc/ssh/sshd_config

	cd $HOME
	git clone git://dpdk.org/dpdk
	cd dpdk
	git checkout v2.1.0
	make install T=${RTE_TARGET} -j2
}


function compile_pktgen
{
	export RTE_SDK="$HOME/dpdk"
	export RTE_TARGET="x86_64-native-linuxapp-gcc"

	cd $HOME
	git clone git://dpdk.org/apps/pktgen-dpdk
	cd pktgen-dpdk
	git checkout pktgen-2.9.8
	make -j2
}

function configure_dpdk
{
	export RTE_TARGET="x86_64-native-linuxapp-gcc"

	cd ~/dpdk

	sudo modprobe uio_pci_generic

	#0000:00:03.0 dedicated to vagrant for ssh, fixed at 10.0.2.15
	#0000:00:08.0 for non-DPDK communication between machines
	#0000:00:09.0 for DPDK comm gen->recv
	#0000:00:0a.0 for DPDK comm recv->gen
	sudo tools/dpdk_nic_bind.py -b uio_pci_generic 0000:00:09.0
	sudo tools/dpdk_nic_bind.py -b uio_pci_generic 0000:00:0a.0

	TMPFILE=$(mktemp)
	for d in /sys/devices/system/node/node? ; do
		echo "echo 0 > $d/hugepages/hugepages-2048kB/nr_hugepages" >> ${TMPFILE}
	done
	sudo sh ${TMPFILE}
	rm ${TMPFILE}

	sudo sh -c 'echo 256 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages'

	# mount hugepages
	sudo mkdir -p /mnt/huge
	sudo chmod 777 /mnt/huge
	sudo mount huge /mnt/huge -t hugetlbfs -o defaults
}


### PM2 Stuff

function unpack_pm2
{
	mkdir -p /vagrant/dist
	[ ! -f /vagrant/dist/pm2-2015-02-11.tar.bz2 ] && cd /vagrant/dist && wget https://gforge.inria.fr/frs/download.php/file/34475/pm2-2015-02-11.tar.bz2
	[ ! -f /vagrant/dist/mpibenchmark-0.2.tar.gz ] && cd /vagrant/dist && wget https://gforge.inria.fr/frs/download.php/file/35459/mpibenchmark-0.2.tar.gz
	mkdir ~/pm2
	cd ~/pm2
	rm -rf ~/pm2/pm2* ~/pm2/mpibenchmark*
	tar xvf /vagrant/dist/pm2-2015-02-11.tar.bz2
	tar xvf /vagrant/dist/mpibenchmark-0.2.tar.gz
}

function sync_pm2
{
	mkdir -p $HOME/pm2/pm2-2015-02-11 $HOME/pm2/mpibenchmark-0.2
	rsync -av --delete /vagrant/dist/pm2-2015-02-11/. $HOME/pm2/pm2-2015-02-11/.
	rsync -av --delete /vagrant/dist/mpibenchmark-0.2/. $HOME/pm2/mpibenchmark-0.2/.
}

function compile_pm2
{
	. ~/.bashrc
	. /vagrant/scripts/bashrc
	set_pm2
	#sync_pm2
	make_pm2
	make_bench
}


### Do Stuff

if [[ "$1" = "setup" ]]; then
	echo SETUP
	install_dependencies
	add_hosts
	export_pubkey

	#compile_dpdk
	#compile_pktgen
	unpack_pm2
	#compile_pm2
elif [[ "$1" = "always" ]]; then
	echo ALWAYS
	import_pubkey

	#configure_dpdk
fi
