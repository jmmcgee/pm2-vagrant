# -*- mode: ruby -*-
# vi: set ft=ruby :

require File.dirname(__FILE__) + '/vagrant-provision-reboot-plugin'

Vagrant.configure(2) do |config|
    config.vm.define "generator" do |generator|
        generator.vm.box = "ubuntu/trusty64"
        generator.vm.network "private_network", ip: "10.0.0.12"
        config.vm.provider "virtualbox" do |vb|
            #vb.name = "generator"
            vb.memory = "2048"
            vb.cpus = 2
            vb.gui = false
            vb.linked_clone = true
            vb.customize ["modifyvm", :id, "--nic3", "intnet"]
            vb.customize ["modifyvm", :id, "--nic4", "intnet"]
            vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
            vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
            vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
            vb.customize ["modifyvm", :id, "--nictype4", "virtio"]
            vb.customize ["modifyvm", :id, "--intnet3", "gentorcv"]
            vb.customize ["modifyvm", :id, "--intnet4", "rcvtogen"]
            vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
            vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
            vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
            vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]
        end
        generator.vm.provision :shell, inline: "echo generator > /etc/hostname",:privileged => true 
        generator.vm.provision :shell, path: "install-generator.sh", :privileged => false
        generator.vm.provision :unix_reboot
        generator.vm.provision :shell, path: "compile-dpdk.sh", :privileged => false
        generator.vm.provision :shell, path: "compile-pktgen.sh", :privileged => false
        generator.vm.provision :shell, path: "configure-dpdk.sh", :privileged => false, run: "always"
    end


    config.vm.define "receiver" do |receiver|
        receiver.vm.box = "ubuntu/trusty64"
        receiver.vm.network "private_network", ip: "10.0.0.13"
        receiver.vm.network "private_network", ip: "10.0.0.14"
        receiver.vm.network "private_network", ip: "10.0.0.15"
        config.vm.provider "virtualbox" do |vb|
            #vb.name = "receiver"
            vb.memory = "1024"
            vb.cpus = 1
            vb.gui = false
            vb.linked_clone = true
            vb.customize ["modifyvm", :id, "--nic3", "intnet"]
            vb.customize ["modifyvm", :id, "--nic4", "intnet"]
            vb.customize ["modifyvm", :id, "--nictype1", "virtio"]
            vb.customize ["modifyvm", :id, "--nictype2", "virtio"]
            vb.customize ["modifyvm", :id, "--nictype3", "virtio"]
            vb.customize ["modifyvm", :id, "--nictype4", "virtio"]
            vb.customize ["modifyvm", :id, "--intnet3", "gentorcv"]
            vb.customize ["modifyvm", :id, "--intnet4", "rcvtogen"]
            vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
            vb.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
            vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.1", "1"]
            vb.customize ["setextradata", :id, "VBoxInternal/CPUM/SSE4.2", "1"]
        end
        receiver.vm.provision :shell, inline: "echo receiver > /etc/hostname",:privileged => true 
    end

end
