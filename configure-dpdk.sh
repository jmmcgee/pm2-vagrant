#!/bin/bash

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
