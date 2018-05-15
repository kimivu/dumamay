#!/bin/bash
VPNCHECK=0
while (($VPNCHECK==0)); do
	ifconfig ppp0 &> /dev/null && VPNCHECK=1 && echo "VPN is active!!!!!!!!!!!!!!!!!!!"
done