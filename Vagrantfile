# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "centos/8"

  config.vm.provision :shell, inline: <<-end
    set -xe
    dnf update -y --refresh
    dnf copr enable pvalena/vagrant -y
    dnf install -y vagrant{,-libvirt} '*/bin/virsh'
  end

  config.vm.provision :shell, run: 'always', privileged: false, inline: <<-end
    set -xe
    cd /vagrant
    ./run.sh
  end

  config.vm.provider :libvirt do |v|
    v.memory = 2048
    v.cpus = 2
    v.nested = true
  end
end
