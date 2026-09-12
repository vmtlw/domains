#!/usr/bin/bash
set -e

git_tmp_dir=/tmp/domains-$(date +%F-%H-%M-%S)
trap 'rm -rf "$git_tmp_dir"' EXIT
git clone git@github.com:vmtlw/domains.git "$git_tmp_dir"

changed=0
added_domains=()

for url in "$@"; do
    # Убираем http:// или https://
    domain="${url#http://}"
    domain="${domain#https://}"

    # Убираем путь, query string и fragment
    domain="${domain%%/*}"
    domain="${domain%%\?*}"
    domain="${domain%%#*}"

    if [[ -z "$domain" ]]; then
        echo "invalid URL: $url"
        continue
    fi

    if grep -qw "$domain" "$git_tmp_dir/dnsmasq.lst"; then
        echo "dns $domain already exists"
    else
        echo "nftset=/$domain/4#inet#fw4#vpn_domains" >> "$git_tmp_dir/dnsmasq.lst"
        echo "dns $domain added"
        added_domains+=("$domain")
        changed=1
    fi
done

if [[ $changed -eq 1 ]]; then
    sort -u "$git_tmp_dir/dnsmasq.lst" -o "$git_tmp_dir/dnsmasq.lst"

    cd "$git_tmp_dir"
    git add dnsmasq.lst
    git commit -m "added domains: ${added_domains[*]}"
    git push

    ssh 10.0.0.1 service getdomains restart
else
    echo "no changes"
fi
