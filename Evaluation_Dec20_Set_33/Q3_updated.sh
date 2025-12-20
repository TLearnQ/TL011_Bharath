#!/bin/bash
set -e

echo "IP Configuration Detection"
echo

PRIMARY_IF=$(ip route show default | awk '{print $5}' | head -n 1)

if [ -z "$PRIMARY_IF" ]; then
    echo "Could not detect primary network interface"
    exit 1
fi

echo "Primary Interface : $PRIMARY_IF"
echo


IP_INFO=$(ip addr show "$PRIMARY_IF")

MODE="UNKNOWN"
REASON="No clear DHCP or static indicators found"

if echo "$IP_INFO" | grep -q "scope global dynamic"; then
    MODE="DHCP"
    REASON="Interface marked as 'dynamic' by kernel"
fi


if [ -f /var/lib/dhcp/dhclient.leases ]; then
    if grep -q "$PRIMARY_IF" /var/lib/dhcp/dhclient.leases; then
        MODE="DHCP"
        REASON="dhclient lease file found for interface"
    fi
fi

if [ "$MODE" = "UNKNOWN" ] && echo "$IP_INFO" | grep -q "scope global"; then
    MODE="STATIC (Likely)"
    REASON="Global IP present but no DHCP indicators"
fi

echo "IP Configuration : $MODE"
echo "Reason           : $REASON"
echo

echo "Notes:"
echo "- DHCP interfaces usually show 'dynamic' or lease files"
echo "- Static IPs do not leave strong runtime evidence"
echo "- This method is safe and works on most Linux systems"

