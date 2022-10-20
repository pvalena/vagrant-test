# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "fedora/36-cloud-base"

  config.vm.provision :shell, inline: <<-end
    ls /vagrant
  end

  config.vm.provision :shell, inline: <<-end
    set -xe
    dnf update -y --refresh
    dnf install -y vagrant{,-libvirt} '*/bin/virsh'
    systemctl enable --now libvirtd
  end

  config.vm.provision :shell, run: 'always', privileged: false, inline: <<-end
    set -xe
  end

  config.vm.provider :libvirt do |v|
    v.memory = 4192
    v.cpus = 2
    # https://nts.strzibny.name/inception-running-vagrant-inside-vagrant-with-kvm/
    v.nested = true
    v.cpu_mode = "host-model"
  end
end
