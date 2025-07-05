#!/bin/sh

# Get basic network information
IP_ADDRESS=$(scutil --nwi | grep address | sed 's/.*://' | tr -d ' ' | head -1)
IS_VPN=$(scutil --nwi | grep -m1 'utun' | awk '{ print $1 }')
SERVICES=$(networksetup -listnetworkserviceorder)
SSID=$(networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}' | xargs networksetup -getairportnetwork | sed -n "s/Current Wi-Fi Network: \(.*\)/\1/p")

# Function to detect Tailscale
detect_tailscale() {
    # Check if Tailscale is running and connected
    if command -v tailscale >/dev/null 2>&1; then
        # Try using jq first (more reliable)
        if command -v jq >/dev/null 2>&1; then
            local ts_status=$(tailscale status --json 2>/dev/null | jq -r '.BackendState // empty' 2>/dev/null)
            local self_online=$(tailscale status --json 2>/dev/null | jq -r '.Self.Online // false' 2>/dev/null)
            if [[ "$ts_status" == "Running" && "$self_online" == "true" ]]; then
                return 0
            fi
        else
            # Fallback to grep/cut if jq is not available
            local ts_status=$(tailscale status --json 2>/dev/null | grep -o '"BackendState":"[^"]*"' | cut -d'"' -f4)
            if [[ "$ts_status" == "Running" ]]; then
                return 0
            fi
        fi

        # Also check simple status output as backup
        local simple_status=$(tailscale status 2>/dev/null | head -1)
        if echo "$simple_status" | grep -q "100\."; then
            return 0
        fi
    fi

    return 1
}

# Function to check if we're actually using a VPN (not just utun interfaces)
is_vpn_active() {
    # Check if the PRIMARY default route goes through a utun interface
    local primary_default=$(netstat -rn -f inet | grep "^default" | head -1)
    if echo "$primary_default" | grep -q "utun"; then
        return 0
    fi

    # Check if ANY default route goes through a utun interface (some VPNs add secondary routes)
    local utun_default_routes=$(netstat -rn -f inet | grep "^default.*utun" | wc -l)
    if [[ $utun_default_routes -gt 0 ]]; then
        return 0
    fi

    # Check if any utun interface has an actual IP address assigned
    # This is a strong indicator of an active VPN connection
    local active_utun_with_ip=$(ifconfig | grep -A 1 "^utun" | grep "inet " | head -1)
    if [[ -n "$active_utun_with_ip" ]]; then
        return 0
    fi

    return 1
}

# Function to get VPN exit country
get_vpn_country() {
    local country=""

    # Method 1: Primary IP geolocation service
    if command -v curl >/dev/null 2>&1; then
        country=$(curl -s --max-time 3 "https://ipinfo.io/country" 2>/dev/null | tr '[:lower:]' '[:upper:]' | tr -d '\n\r ')
        if [[ ${#country} -eq 2 ]] && [[ "$country" =~ ^[A-Z]{2}$ ]]; then
            echo "$country"
            return 0
        fi
    fi

    # Method 2: Backup geolocation service (skip ipapi.co as it's rate limited)
    if command -v curl >/dev/null 2>&1; then
        country=$(curl -s --max-time 3 "https://api.country.is/" 2>/dev/null | grep -o '"country":"[^"]*"' | cut -d'"' -f4 | tr '[:lower:]' '[:upper:]')
        if [[ ${#country} -eq 2 ]] && [[ "$country" =~ ^[A-Z]{2}$ ]]; then
            echo "$country"
            return 0
        fi
    fi

    # If we can't determine country but VPN is active, return generic VPN
    echo "VPN"
    return 0
}

# Function to detect VPN type and status
detect_vpn_status() {
    # Check for other VPN connections first (non-Tailscale)
    if is_vpn_active; then
        # If not Tailscale, show country, else show TS
        if ! detect_tailscale >/dev/null; then
            local country=$(get_vpn_country)
            if [[ -n "$country" ]]; then
                echo "$country"
                return 0
            else
                echo "VPN"
                return 0
            fi
        else
            # Both Tailscale and VPN active - show VPN country
        	echo "TS"
            return 0
        fi
    fi

    # Check for Tailscale only (no other VPN)
    if detect_tailscale >/dev/null; then
        echo "TS"
        return 0
    fi

    return 1
}

# Determine display based on connection status
VPN_STATUS=$(detect_vpn_status)
VPN_ACTIVE=$?

if [[ $VPN_ACTIVE -eq 0 ]]; then
    # VPN is active - include VPN status in icon
    ICON="􁅏→$VPN_STATUS"
    if [[ $IP_ADDRESS != "" ]]; then
        # Show IP address only in label
        LABEL="$IP_ADDRESS"
    else
        # VPN only, no additional label needed
        LABEL=""
    fi
elif [[ $IP_ADDRESS != "" ]]; then
    # WiFi connected, no VPN
    case $SSID in
        *iPhone*) ICON="􀉤";;
        *)        ICON="􀙇";;
    esac
    LABEL=$IP_ADDRESS
elif [[ $SERVICES == "iPhone USB" ]]; then
    ICON="􁈩"
    LABEL="iPhone USB"
elif [[ $SERVICES == "Thunderbolt Bridge" ]]; then
    ICON="􀒘"
    LABEL="Thunderbolt Bridge"
else
    ICON="􀙈"
    LABEL="Not Connected"
fi

sketchybar --set $NAME \
    icon=$ICON \
    label="$LABEL"
