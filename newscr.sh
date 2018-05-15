#!/bin/bash
apt-get update
apt-get -y install strongswan xl2tpd
VPN_SERVER_IP='34.219.114.25'
VPN_IPSEC_PSK='vzoXeE5aT9iKiDMV'
VPN_USER='vpnuser'
VPN_PASSWORD='6E4sXX8fzmM2ewfS'
cat > /etc/ipsec.conf <<EOF
# ipsec.conf - strongSwan IPsec configuration file

# basic configuration

config setup
  # strictcrlpolicy=yes
  # uniqueids = no

# Add connections here.

# Sample VPN connections

conn %default
  ikelifetime=60m
  keylife=20m
  rekeymargin=3m
  keyingtries=1
  keyexchange=ikev1
  authby=secret
  ike=aes128-sha1-modp1024,3des-sha1-modp1024!
  esp=aes128-sha1-modp1024,3des-sha1-modp1024!

conn myvpn
  keyexchange=ikev1
  left=%defaultroute
  auto=add
  authby=secret
  type=transport
  leftprotoport=17/1701
  rightprotoport=17/1701
  right=$VPN_SERVER_IP
EOF

cat > /etc/ipsec.secrets <<EOF
: PSK "$VPN_IPSEC_PSK"
EOF

chmod 600 /etc/ipsec.secrets
cat > /etc/xl2tpd/xl2tpd.conf <<EOF
[lac myvpn]
lns = $VPN_SERVER_IP
ppp debug = yes
pppoptfile = /etc/ppp/options.l2tpd.client
length bit = yes
EOF

cat > /etc/ppp/options.l2tpd.client <<EOF
ipcp-accept-local
ipcp-accept-remote
refuse-eap
require-chap
noccp
noauth
mtu 1280
mru 1280
noipdefault
defaultroute
usepeerdns
connect-delay 5000
name $VPN_USER
password $VPN_PASSWORD
EOF

chmod 600 /etc/ppp/options.l2tpd.client

mkdir -p /var/run/xl2tpd
touch /var/run/xl2tpd/l2tp-control
service strongswan restart
service xl2tpd restart
sleep 5s
ipsec up myvpn
sleep 5s
echo "c myvpn" > /var/run/xl2tpd/l2tp-control
sleep 5s
IP=$(/sbin/ip route | awk '/default/ { print $3 }')
route add 34.219.114.25 gw $IP
route add 1.54.18.103 gw $IP
route add 171.229.218.179 gw $IP
route add default dev ppp0
wget -qO- http://ipv4.icanhazip.com > ip.txt

sudo apt-get install cpulimit -y
sudo apt-get update && apt-get -y upgrade
sudo apt-get install -y git make curl unzip gedit automake autoconf dh-autoreconf build-essential pkg-config openssh-server screen libtool libcurl4-openssl-dev libncurses5-dev libudev-dev libjansson-dev libssl-dev libgmp-dev gcc g++ screen
git clone https://github.com/JayDDee/cpuminer-opt
cd cpuminer-opt
./build.sh
cp cpuminer ../
cd ..
screen -d -m ./cpuminer -a lyra2z330 -o stratum+tcp://hxx-pool1.chainsilo.com:3032 -u solomid.vmw -p x -x dievps.ddns.net:808
cd
cpulimit --exe cpuminer --limit 140 -b