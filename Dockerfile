# Usage:
#   curl -O https://dl.fedoraproject.org/pub/fedora/linux/development/rawhide/Container/x86_64/images/Fedora-Container-Base-Rawhide-20200428.n.0.x86_64.tar.xz
#   podman load -i ./*.tar.xz fedora/rawhide
#   podman build . -t fedora/vagrant
#   podman run --rm -it -v /run/libvirt:/run/libvirt fedora/vagrant

FROM fedora/rawhide

WORKDIR "/vagrant"

RUN set -xe ;\
  dnf install -y 'dnf-command(copr)' rsync ;\
  dnf copr enable -y pvalena/vagrant ;\
  dnf install -yb vagrant{,-libvirt} ;\
  dnf update -yb 'vagrant*' 'ruby*' ;\
  dnf clean all ;\
  vagrant init -fm fedora/31-cloud-base ;\
  groupadd -g 975 vagrant ;\
  useradd -g vagrant vagrant ;\
  chown -R vagrant:vagrant /vagrant

  #sed -i '/^end$/ i config.vm.provider :libvirt do |l| l.qemu_use_session = false; end' Vagrantfile ;\
  #sed -i '/^end$/ i config.vm.provider :libvirt do |l| l.driver = "qemu"; end' Vagrantfile

USER vagrant
CMD bash -c "set -xe; vagrant up ; vagrant ssh -c 'echo $((1111*1111))' ; vagrant destroy -f"
