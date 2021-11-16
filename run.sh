#!/bin/bash
set -xe
set -o pipefail
bash -n "$0"
f="vagrant_smoke_test.log"
./tv.sh 2>&1 | tee "$f"

O="$(
    cat -v "$f" \
     | sed -e 's/\^M\^\[\[K/\n/g' \
     | grep -vE '^Progress: [0-9]*%' \
     | sed -e 's|/home/lpcs/||g' \
     | sed -e 's|lpcsf-new/test/fedora/vagrant/||g'
  )"

#     | grep -v '\^M^'

#P=""
#while [[ "$O" != "$P" ]]; do
#  P="$O"
#  O="$( sed -e 's/Progress: [0-9]+ \(Progress: \)/\1/g' <<< "$P" )"
#done

echo "$O" > "$f"

nn "$f"

[[ -n "$(grep -v '^$' "$f")" ]] \
  && gist -sf "$f" "$f"
