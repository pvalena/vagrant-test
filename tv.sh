#!/bin/zsh

P='vagrant{,-{libvirt,cloud,sshfs,managed-servers}} ruby{,gem{s,-{listen,bcrypt_pbkdf,ed25519,net-{ssh,scp},i18n,childprocess,ruby-libvirt,fog-{core,json,libvirt}}}}'
F=35
C=8

tv() {
  v 'ssh -c "let \"n=11*11\" ; echo \${n}"' | tee -a /dev/stderr \
    | grep -q 121 && {
      echo '--> Ok'
      return 0
    }

  let "x = ${1:-1} - 1"
  [[ "$x" -gt 0 ]] || return 1

  echo '--> Retry'
  tv "$x"
  return $?
}

v() {
  a=""
  [[ -n "$DEBUG" ]] && a="${a} --debug"
  O="$(bash -c "set -x ; vagrant ${1}${a}")"
  rc=$?
  grep -v '^$' <<< "$O"
  s
  return $rc
}

s() {
  sleep "$i"
}

set -e

m="`readlink -e "$0"`"
[[ -x "$m" ]] || exit 1
bash -n "$m" || exit 1

d="`dirname "$m"`"
v="$d/voldel"

[[ "$1" == "-d" ]] && {
  DEBUG="$1"
  shift
  :
} || DEBUG=

[[ "$1" == "-i" ]] && {
  i="$2"
  shift 2
  :
} || i=0.2

[[ "$1" == "-l" ]] && {
  l="$1"
  shift
  :
} || l=

[[ -z "$1" || -n "$l" ]] && {
  echo "RPMs:"
  bash -c "rpm -q $P" | xargs -i bash -c "echo ' - {}' | sort -u"
  echo
  bash -c "dnf -q list $P"

  [[ -n "$l" ]] && exit 0

  echo
  ls */Vagrantfile | xargs -rn1 sed -i -e "s|\(\s*=\s*.fedora\/\)[0-9]*\-|\1${F}\-|"
  ls */Vagrantfile | xargs -rn1 sed -i -e "s|\(\s*=\s*.centos\/\)[0-9]*\-|\1${C}\-|"

  cd 1
  set -e
    echo ">>> Smoke test"
    vagrant destroy -f || :
    vagrant init -fm "fedora/${F}-cloud-base"
    vagrant up -v
    s
    echo
    vagrant global-status
    echo
    vagrant global-status | grep '/test/fedora/vagrant/test/' | cut -d' ' -f1  | xargs -rn1 vagrant destroy -f
    echo
  cd "$d"
  set +e

  # Real tests
  ls -d */ | sort -n | xargs -ri bash -c "$m ${DEBUG} '{}' || exit 255"
  rc=$?
  virsh vol-list --pool default | grep '\-VAGRANTSLASH-' | cut -d' ' -f2  | xargs -rn1 virsh vol-delete --pool default
  exit $rc
}

[[ -d "$1" ]] || exit 1
cd "$1"
echo -e ">>> TEST `basename "$1"`"
cat Vagrantfile

s=.skip
[[ -f "$s" ]] && {
  n='============================================================'

  echo -n '--> Skip: '
  head -n 1 "$s"

  echo "${n}"
  tail -n +2 "$s"
  echo "${n}"

  exit 0
}

b="`grep '\.box = ' Vagrantfile | rev | cut -d'"' -f2 | rev`"
[[ -z "$b" ]] && exit 1

vagrant box list | cut -d' ' -f1 | xargs -i bash -c \
  " [[ '{}' == '$b' ]] || { touch '$v' ; } ; "
#  " [[ '{}' == '$b' ]] || { vagrant box remove '{}' && touch '$v' ; } ; "

for c in up halt up 'destroy -f'; do
  v status
  v "$c" && {
    [[ "$c" == "halt" || "$c" == "destroy -f" ]] || \
    tv 3
  } || {
    echo "--> Fail: $c"
    exit 1
  }
done

v status
touch "$v"
echo '--> Success!'
echo
exit 0
