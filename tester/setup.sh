# Use apt-acacher if on a virtual machine
VMXNET=$(cat /proc/modules | grep -q vmxnet; echo $?)
if [ $VMXNET -eq 0 ]; then
  echo "On virtual machine, setting up apt proxy"
  GATEWAY=$(ip route show | grep ^default | cut -d' ' -f 3)
  HOST="$(echo -n $GATEWAY | cut -d . -f 1-3).$(($(echo $GATEWAY | cut -d . -f 4 )-1))"
  echo "Acquire::http { Proxy \"http://$HOST:3142\"; };" >> /etc/apt/apt.conf.d/01proxy
fi

# To prevent warnings about missing locales if we 
# SSH from a norwegian system 

apt-get update --yes

apt-get install --yes language-pack-nb

apt-get install --yes vim git build-essential libpcap0.8 libpcap-dev snmp samba ntp

# Fix for libpcap (hping)
ln -s /usr/include/pcap/bpf.h /usr/include/net/bpf.h

