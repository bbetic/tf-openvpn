#!/bin/bash
#
# openvpn-exclude.sh
#
# Excludes specified IPs or domains from the OpenVPN tunnel by adding
# static routes via the default local gateway.
#
# Usage: ./openvpn-exclude.sh [domain or IP] ...

set -e

# Function to get the default gateway
get_default_gateway() {
    # If OpenVPN calls this script, it sets route_net_gateway
    if [ -n "$route_net_gateway" ]; then
        echo "$route_net_gateway"
        return
    fi

    # Fallback for standalone mode: try to find the gateway that is NOT the VPN.
    # This is tricky because if VPN is up, 'default' often points to VPN.
    # We look for the gateway of the interface that provides internet access.
    # A common heuristic is looking for the route with the lowest metric or specific interface.

    # However, a simpler approach for standalone use is to assume the user provides it
    # or we try to deduce it from 'ip route'.
    # For now, let's try to find the default gateway that is not a tun/tap device.

    # This command lists routes, filters for 'default', and excludes 'tun' or 'tap'.
    # Note: This might need adjustment based on specific network setups.
    local gw=$(ip route show default | grep -v 'tun\|tap' | awk '/default/ {print $3}' | head -n 1)

    if [ -z "$gw" ]; then
        # If we can't find it easily, maybe we are not connected to VPN yet?
        # Or maybe we just take the current default.
        gw=$(ip route show default | awk '/default/ {print $3}' | head -n 1)
    fi

    echo "$gw"
}

resolve_ip() {
    local target="$1"
    # Check if it's already an IP
    if [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$target"
        return
    fi

    # Try resolving with getent (common on Linux)
    local ips=$(getent ahosts "$target" | awk '{print $1}' | sort -u)

    if [ -n "$ips" ]; then
        echo "$ips"
    else
        echo "Could not resolve $target" >&2
    fi
}

add_route() {
    local ip="$1"
    local gw="$2"

    if [ -z "$ip" ] || [ -z "$gw" ]; then
        return
    fi

    echo "Adding route for $ip via $gw"
    # Suppress error if route exists
    ip route add "$ip" via "$gw" 2>/dev/null || ip route replace "$ip" via "$gw"
}

# Main execution

if [ "$#" -eq 0 ]; then
    echo "Usage: $0 [domain or IP] ..."
    exit 1
fi

GATEWAY=$(get_default_gateway)

if [ -z "$GATEWAY" ]; then
    echo "Error: Could not determine default gateway."
    exit 1
fi

echo "Using Gateway: $GATEWAY"

for target in "$@"; do
    IPS=$(resolve_ip "$target")
    for ip in $IPS; do
        add_route "$ip" "$GATEWAY"
    done
done

echo "Done."
