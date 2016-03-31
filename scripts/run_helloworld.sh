# build helloworld if not built
if [ ! -f $RTE_SDK/examples/helloworld/build/helloworld ]; then
    cd $RTE_SDK/examples/helloworld
    make
fi

cd ~/dpdk/examples/helloworld/build
sudo ./helloworld $RTE_EAL $RTE_PCI
