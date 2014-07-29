# For å slippe advarsler om manglende locale om vi
# ssher inn fra et norsk system
apt-get install --yes language-pack-nb

# Install and enable chargen
apt-get install --yes xinetd
service xinetd stop
sed -e 's/disable/disable = no  #/' /etc/xinetd.d/chargen > /etc/xinetd.d/chargen.tmp
mv /etc/xinetd.d/chargen.tmp /etc/xinetd.d/chargen
service xinetd start

# Unrestrict the NTP service
service ntp stop
sed -e 's/^restrict/#restrict/' /etc/ntp.conf > /etc/ntp.conf.tmp
mv /etc/ntp.conf.tmp /etc/ntp.conf
service ntp start

# Install an enable a dns service
apt-get install --yes dnsmasq
service dnsmasq stop
echo 'txt-record=large.txt.record.com,"This could have been a REALLY LARGE txt record, but i will stop here."' >> /etc/dnsmasq.conf

service dnsmasq start

IP=$(hostname -I | cut -d' ' -f 2)
echo The server IP is $IP.
echo
echo Use the following commands for testing:
echo NTP READVAR:  ntpq -c rv $IP
echo NTP MONLIST:  ntpdc -n -c monlist $IP
echo 'CHARGEN:      echo "" | nc -q 2 -u '$IP' 19'
echo DNS:          dig +short TXT @$IP large.txt.record.com
