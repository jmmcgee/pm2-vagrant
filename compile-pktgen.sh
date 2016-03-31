#!/bin/bash

export RTE_SDK="$HOME/dpdk"
export RTE_TARGET="x86_64-native-linuxapp-gcc"

cd $HOME
git clone git://dpdk.org/apps/pktgen-dpdk
cd pktgen-dpdk
git checkout pktgen-2.9.8
make -j2
