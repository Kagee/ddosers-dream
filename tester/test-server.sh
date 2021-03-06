#! /bin/bash
if [[ "$#" -eq 1 ]]; then
  SIP=$1
  function VERB { return; }
elif [[ "$#" -eq 2 ]]; then
  SIP=$2
  function VERB { UGLY "$1"; }
else
  echo "Usage:"
  echo "$0 -v <ip> (verbose)"
  echo "$0 <ip>"
  exit
fi
function GOOD {
  echo -e "\e[32m\e[1m$1\e[0m"
}
function BAD {
  echo -e "\e[31m\e[1m$1\e[0m"
}
function UGLY {
  echo -e >&2 "\e[33m\e[1m$1\e[0m"
}

function _readvar {
    # NTP READVAR
    if [ $(hash ntpq 2>/dev/null; echo $?) -eq 0 ]; then
      GOOD "Testing NTP READVAR";
      R=$(ntpq -c rv $1 2>&1; echo $?)
      VERB "$R"
      if [ $(echo "$R" | grep -q -E "nothing received|Connection refused"; echo $?) -ne 0 ]; then
        BAD "The NTP service at $1:123 responds to READVAR requests"
      else
        GOOD "The NTP service at $1:123 does not respond to READVAR requests"
      fi
    else
      UGLY "I require ntpq to test NTP READVAR, but it's not installed.";
    fi
}

function _monlist {
    # NTP MONLIST
    if [ $(hash ntpdc 2>/dev/null; echo $?) -eq 0 ]; then
      GOOD "Testing NTP MONLIST";
      R=$(ntpdc -n -c monlist $1 2>&1; echo $?)
      VERB "$R"
      if [ $(echo "$R" | grep -q "nothing received|Connection refused"; echo $?) -ne 0 ]; then
        BAD "The NTP service at $1:123 responds to MONLIST requests"
      else
        GOOD "The NTP service at $1:123 does not respond to MONLIST requests"
      fi

    else
      UGLY "I require ntpdc to test NTP MONLIST, but it's not installed.";
    fi
}

function _openresolver {
    # DNS OPENRESOLVER
    if [ $(hash dig 2>/dev/null; echo $?) -eq 0 ]; then
      GOOD "Testing DNS OPENRESOLVER";
      R=$(dig +short test.openresolver.com TXT @$1 2>&1)
      VERB "$R"  
      if [ $(echo "$R" | grep -q open-resolver-detected; echo $?) -eq 0 ]; then
        BAD "The DNS service at $1:53 is an open resolver"
      else
        GOOD "The DNS service at $1:53 is not an open resolver"
      fi
    else
      UGLY "I require dig to test DNS OPENRESOLVER, but it's not installed.";
    fi
}

function _snmp {
    #SNMP
    if [ $(hash snmpget 2>/dev/null; echo $?) -eq 0 ]; then
      GOOD "Testing SNMP";
      R=$(snmpget -c public -v 2c $1 1.3.6.1.2.1.1.1.0 2>&1)
      VERB "$R"  
      if [ $(echo "$R" | grep -q 'iso.3.6.1.2.1.1.1.0'; echo $?) -eq 0 ]; then
        BAD "The SNMP service at $1 responds to queries"
      else
        GOOD "The SNMP service at $1 does not respond to queries"
      fi
    else
      UGLY "I require snmpget to test SNMP, but it's not installed.";
    fi
}

function _netbios {
    # NETBIOS
    if [ $(hash nmblookup 2>/dev/null; echo $?) -eq 0 ]; then
      GOOD "Testing NETBIOS";
      R=$(nmblookup -A $1 2>&1)
      VERB "$R"
      if [ $(echo "$R" | grep -q 'No reply'; echo $?) -ne 0 ]; then
        BAD "The netbios service at $1:137 responds to queries"
      else
        GOOD "The netbios service at $1:137 does not responds to queries"
      fi
    else
      UGLY "I require nmblookup to test NETBIOS, but it's not installed.";
    fi
}

function _chargen {
    if [ $(hash nc 2>/dev/null; echo $?) -eq 0 ]; then
      GOOD "Testing CHARGEN";
      R=$(echo "" | nc -q 2 -u $1 19 2>&1)
      VERB "$R"
      if [ $(echo "$R" | grep -q 'ABCDEFG'; echo $?) -eq 0 ]; then
        BAD "The chargen service at $1:19 responds to queries"
      else
        GOOD "The chargen service at $1:19 does not responds to queries"
      fi
    else
      UGLY "I require nc to test CHARGEN, but it's not installed.";
    fi
}

function _ssdp {
    #SSDP
    if [ $(hash nc 2>/dev/null; echo $?) -eq 0 ]; then
      GOOD "Testing SSDP";
      UGLY "I don't know how to test SSDP...."
      #R=$(echo "" | nc -q 2 -u $1 19)
      #VERB "$R"
      #if [ $(echo "$R" | grep -q 'ABCDEFG'; echo $?) -eq 0 ]; then
      #  BAD "The chargen service at $1:19 responds to queries"
      #else
      #  BAD "The chargen service at $1:19 does not responds to queries"
      #fi

      # Need to get better test (listen and recive on same port)
      #echo "Testing SSDP"
      #echo -n -e "M-SEARCH * HTTP/1.1\\r\\n"\
      #"Host:239.255.255.250:1900\\r\\n"\
      #"ST:upnp:rootdevice\\r\\n"\
      #"Man:\"ssdp:discover\"\\r\\n"\
      #"MX:3\\r\\n\\r\\n" | \
      #nc -q 1 -p 1900 -s <SRC_IP> -u 172.16.117.134  1900
    else
      UGLY "I require nc to test SSDP, but it's not installed.";
    fi
}

NAME=$(basename "$0")

if [ $(declare -f -F "_$NAME" > /dev/null; echo $?) -eq 0 ]; then
 _$NAME $SIP
else
  _readvar $SIP
  _monlist $SIP
  _openresolver $SIP
  _snmp $SIP
  _netbios $SIP
  _chargen $SIP
  _ssdp $SIP
fi
