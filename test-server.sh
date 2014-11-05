#! /bin/bash
if [[ "$#" -eq 1 ]]; then
  SIP=$1
  function VERB { return; }
elif [[ "$#" -eq 2 ]]; then
  SIP=$2
  function VERB { echo "$1"; }
else
  echo "Usage:"
  echo "$0 -v <ip> (verbose)"
  echo "$0 <ip>"
  exit
fi
function GOOD {
  echo -e "\e[32m\e[1mGOOD: $1\e[0m"
}
function BAD {
  echo -e "\e[31m\e[1mBAD: $1\e[0m"
}
function UGLY {
  echo -e >&2 "\e[33m\e[1mUGLY: $1\e[0m"
}



# NTP READVAR
if [ $(hash ntpq 2>/dev/null; echo $?) -eq 0 ]; then
  echo "Testing NTP READVAR";
  ntpq -c rv $SIP
else
  UGLY "I require ntpq to test NTP READVAR, but it's not installed.";
fi

# NTP MONLIST
if [ $(hash ntpdc 2>/dev/null; echo $?) -eq 0 ]; then
  echo "Testing NTP MONLIST";
  ntpdc -n -c monlist $SIP
else
  UGLY "I require ntpdc to test NTP MONLIST, but it's not installed.";
fi

# DNS OPENRESOLVER
if [ $(hash dig 2>/dev/null; echo $?) -eq 0 ]; then
  echo "Testing DNS OPENRESOLVER";
  R=$(dig +short test.openresolver.com TXT @$SIP)
  VERB "$R"  
  if [ $(echo "$R" | grep -q open-resolver-detected; echo $?) -eq 0 ]; then
    BAD "The DNS service at $SIP:53 is a open resolver"
  else
    GOOD "The DNS service at $SIP:53 is a open resolver"
  fi
else
  UGLY "I require dig to test DNS OPENRESOLVER, but it's not installed.";
fi

#SNMP
if [ $(hash snmpget 2>/dev/null; echo $?) -eq 0 ]; then
  echo "Testing SNMP";
  snmpget -c public -v 2c $SIP 1.3.6.1.2.1.1.1.0
else
  UGLY "I require snmpget to test SNMP, but it's not installed.";
fi

# NETBIOS
if [ $(hash nmblookup 2>/dev/null; echo $?) -eq 0 ]; then
  echo "Testing NETBIOS";
  nmblookup -A $SIP
else
  UGLY "I require nmblookup to test NETBIOS, but it's not installed.";
fi

# CHARGEN
#SSDP
if [ $(hash nc 2>/dev/null; echo $?) -eq 0 ]; then
  echo "Testing CHARGEN";
  R=$(echo "" | nc -q 2 -u $SIP 19)
  VERB "$R"
  if [ $(echo "$R" | grep -q 'ABCDEFG'; echo $?) -eq 0 ]; then
    BAD "The chargen service at $SIP:19 responds to queries"
  else
    BAD "The chargen service at $SIP:19 does not responds to queries"
  fi

  # Need to get better test (listen and recive on same port)
  #echo "Testing SSDP"
  #echo -n -e "M-SEARCH * HTTP/1.1\\r\\n"\
  #"Host:239.255.255.250:1900\\r\\n"\
  #"ST:upnp:rootdevice\\r\\n"\
  #"Man:\"ssdp:discover\"\\r\\n"\
  #"MX:3\\r\\n\\r\\n" | \
  #nc -q 1 -p 1900 -s <SRC_IP> -u 172.16.117.134  1900
else
  UGLY "I require nc to test CHARGEN, but it's not installed.";
  UGLY "I require nc to test SSDP, but it's not installed.";
fi
