echo
echo "Linux kernel hardening"
# http://www.cyberciti.biz/faq/linux-kernel-etcsysctl-conf-security-hardening/
echo "--------------------------------------------------------------"
#
cp /etc/sysctl.conf /etc/sysctl.conf.bak
#
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=0/g" /etc/sysctl.conf
sed -i "s/#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=0/g" /etc/sysctl.conf
sed -i "s/#net.ipv4.icmp_echo_ignore_broadcasts = 1/net.ipv4.icmp_echo_ignore_broadcasts = 1/g" /etc/sysctl.conf
sed -i "s/#net.ipv4.icmp_ignore_bogus_error_responses = 1/net.ipv4.icmp_ignore_bogus_error_responses = 1/g" /etc/sysctl.conf
sed -i "s/#net.ipv4.conf.all.accept_redirects = 0/net.ipv4.conf.all.accept_redirects = 0/g" /etc/sysctl.conf
sed -i "s/#net.ipv6.conf.all.accept_redirects = 0/net.ipv6.conf.all.accept_redirects = 0/g" /etc/sysctl.conf
sed -i "s/#net.ipv4.conf.all.send_redirects = 0/net.ipv4.conf.all.send_redirects = 0/g" /etc/sysctl.conf
sed -i "s/#net.ipv4.conf.all.accept_source_route = 0/net.ipv4.conf.all.accept_source_route = 0/g" /etc/sysctl.conf
sed -i "s/#net.ipv6.conf.all.accept_source_route = 0/net.ipv6.conf.all.accept_source_route = 0/g" /etc/sysctl.conf
sed -i "s/#net.ipv4.conf.all.log_martians = 1/net.ipv4.conf.all.log_martians = 1/g" /etc/sysctl.conf
#
echo "#
# Controls the use of TCP syncookies
net.ipv4.tcp_synack_retries = 2

# Increasing free memory
vm.min_free_kbytes = 16384
" >> /etc/sysctl.conf
#
sysctl -p