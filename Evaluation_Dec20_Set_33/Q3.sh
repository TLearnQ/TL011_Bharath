#!/bin/bash

# ----------------------------------------
# Detect if primary interface uses DHCP or Static IP
# Methods:
# 1. ip addr show -> look for "scope global dynamic"
# 2. Check dhclient lease files
# 3. Check NetworkManager lease files
# ----------------------------------------

set -e

echo "=== IP Configuration Detection ==="

# Get primary interface (default route)
PRIMARY_IF=$(ip route | awk '/default/ {print $5; exit}')

if [ -z "$PRIMARY_IF" ]; then
    echo "ERROR: Unable to determine primary interface"
    exit 1
fi

echo "Primary interface detected: $PRIMARY_IF"
echo

DETECTION="UNKNOWN"
REASON=""

# -------------------------------
# Method 1: ip addr show analysis
# -------------------------------
IP_INFO=$(ip addr show "$PRIMARY_IF")

if echo "$IP_INFO" | grep -q "scope global dynamic"; then
    DETECTION="DHCP"
    REASON="Detected 'scope global dynamic' in ip addr output"
elif echo "$IP_INFO" | grep -q "scope global"; then
    DETECTION="STATIC (LIKELY)"
    REASON="Found 'scope global' without 'dynamic' flag"
fi

# --------------------------------
# Method 2: dhclient lease file
# --------------------------------
DHCLIENT_LEASE="/var/lib/dhcp/dhclient.leases"

if [ -f "$DHCLIENT_LEASE" ]; then
    if grep -q "$PRIMARY_IF" "$DHCLIENT_LEASE"; then
        DETECTION="DHCP"
        REASON="dhclient lease entry found for interface in $DHCLIENT_LEASE"
    fi
fi# --------------------------------
# Method 3: NetworkManager leases
# --------------------------------
NM_LEASE_DIR="/var/lib/NetworkManager"

if [ -d "$NM_LEASE_DIR" ]; then
    if ls "$NM_LEASE_DIR"/*lease* 1>/dev/null 2>&1; then
        if grep -R "$PRIMARY_IF" "$NM_LEASE_DIR"/*lease* >/dev/null 2>&1; then
            DETECTION="DHCP"
            REASON="NetworkManager lease file references interface"
        fi
    fi
fi

# -------------------------------
# Output result
# -------------------------------
echo "Detection Result: $DETECTION"
echo "Detection Method:"
echo "  - $REASON"

echo
echo "Justification:"
if [ "$DETECTION" = "STATIC (LIKELY)" ]; then
    echo "  Static IP inferred because no DHCP indicators were found."
    echo "  Note: Static IPs configured via NetworkManager may not"
    echo "  always be distinguishable from DHCP using iproute alone."
elif [ "$DETECTION" = "UNKNOWN" ]; then
    echo "  No definitive DHCP or static indicators found."
    echo "  System may be using alternative network configuration tools."
else
    echo "  DHCP confirmed via runtime or lease-based evidence."
fi

