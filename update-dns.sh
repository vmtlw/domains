#!/usr/bin/bash
set -e

git_tmp_dir=/tmp/domains-$(date +%F-%H-%M-%S)
git clone git@github.com:vmtlw/domains.git "$git_tmp_dir"

changed=0

for domain in "$@"; do
    if grep -qw "$domain" "$git_tmp_dir/dnsmasq.lst"; then
        echo "dns $domain already exists"
    else
        echo "nftset=/$domain/4#inet#fw4#vpn_domains" >> "$git_tmp_dir/dnsmasq.lst"
        echo "dns $domain added"
        changed=1
    fi
done

if [[ $changed -eq 1 ]]; then
    sort -u "$git_tmp_dir/dnsmasq.lst" -o "$git_tmp_dir/dnsmasq.lst"

    cd "$git_tmp_dir"
    git add dnsmasq.lst
    git commit -m "added domains: $*"
    git push

    ssh 10.0.0.1 service getdomains restart
else
    echo "no changes"
fi

rm -rf "$git_tmp_dir"

