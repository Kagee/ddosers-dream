# For å slippe advarsler om manglende locale om vi
# ssher inn fra et norsk system
apt-get install --yes language-pack-nb

# Install and enable chargen
apt-get install --yes xinetd
service xinetd stop
sed -e 's/disable/disable = no  #/' /etc/xinetd.d/chargen > /etc/xinetd.d/chargen.tmp
mv /etc/xinetd.d/chargen.tmp /etc/xinetd.d/chargen
service xinetd start

# Install and unrestrict the NTP service
apt-get install --yes ntp
service ntp stop
sed -e 's/^restrict/#restrict/' /etc/ntp.conf > /etc/ntp.conf.tmp
mv /etc/ntp.conf.tmp /etc/ntp.conf
service ntp start

# Install an enable a dns service
apt-get install --yes dnsmasq # do this last?

service dnsmasq stop
service dnsmasq start

# qotd - quote of the day
# Så lite forskjell til chargen at vi ignorerer

# netbios

# snmp
apt-get install --yes snmpd
service snmpd stop
sed -e 's/.*agentAddress.*//' /etc/snmp/snmpd.conf > /etc/snmp/snmpd.conf.tmp
echo "agentAddress udp:161,udp6:[::1]:161" > /etc/snmp/snmpd.conf
cat /etc/snmp/snmpd.conf.tmp >> /etc/snmp/snmpd.conf
#rm /etc/snmp/snmpd.conf.tmp
service snmpd start

# ssdp
apt-get install --yes mediatomb
service mediatomb start

# ipmi - mulig ?

apt-get install --yes vim most tshark # for development

IP=$(hostname -I)
echo The server IP is $IP.
echo
echo Use the following commands for testing:
echo "NTP READVAR:  ntpq -c rv $IP"
echo "NTP MONLIST:  ntpdc -n -c monlist $IP"
echo 'CHARGEN:      echo "" | nc -q 2 -u '$IP' 19'
echo "DNS:          dig +short test.openresolver.com TXT @$IP"
echo "SNMP:         snmpget -c public -v 2c $IP 1.3.6.1.2.1.1.1.0"
echo "SSDP:"
echo "echo -n -e \"M-SEARCH * HTTP/1.1\\\r\\\n\"\\"
echo "\"Host:239.255.255.250:1900\\\r\\\n\"\\"
echo "\"ST:upnp:rootdevice\\\r\\\n\"\\"
echo "\"Man:\\\"ssdp:discover\\\"\\\r\\\n\"\\"
echo "\"MX:3\\\r\\\n\\\r\\\n\" | \\"
echo "nc -q 1 -p 1900 -s 172.16.201.1 -u 172.16.201.176 1900"
