#!/usr/bin/bash
set +x 
git_tmp_dir=/tmp/domains-$(date +%F-%M-%S)
[[ -d $git_tmp_dir/.git ]] && rm -rf $git_tmp_dir
git clone git@github.com:vmtlw/domains.git $git_tmp_dir
domain=$1
if grep -w $domain $git_tmp_dir/dnsmasq.lst; then 
	echo "dns $domain already exists"
else   
	echo "nftset=/$domain/4#inet#fw4#vpn_domains" >> $git_tmp_dir/dnsmasq.lst
	sort $git_tmp_dir/dnsmasq.lst > /tmp/sorted
	mv /tmp/sorted $git_tmp_dir/dnsmasq.lst
	echo "dns $domain added !"
fi

cd ~
cd $git_tmp_dir;
git add dnsmasq.lst
git commit -m "added $domain"
git push
cd -
ssh 10.0.0.1 service getdomains restart

rm -rf $git_tmp_dir
set -x
