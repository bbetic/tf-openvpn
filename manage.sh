#!/bin/bash
#
# JIT OpenVPN Manager (Pulumi Version)
# Usage:
#   ./manage.sh up    - Spins up the VPN server and downloads config
#   ./manage.sh down  - Destroys the VPN server
#   ./manage.sh status - Shows status and IP

set -e

CONFIG_FILE="client.ovpn"
KEY_FILE="vpn_key.pem"
PULUMI_STACK="dev"

check_deps() {
    if ! command -v pulumi &> /dev/null; then
        echo "Error: pulumi is not installed."
        exit 1
    fi
}

setup_backend() {
    # Always use local state.
    # In CI, the workflow handles exporting/importing this state via Artifacts.
    pulumi login --local
}

notify() {
    echo "---------------------------------------------------"
    echo "NOTIFICATION: $1"
    echo "---------------------------------------------------"

    if [ "$CI" = "true" ]; then
        return
    fi

    if command -v osascript &> /dev/null; then
        osascript -e "display notification \"$1\" with title \"OpenVPN JIT\""
    fi
    if command -v notify-send &> /dev/null; then
        notify-send "OpenVPN JIT" "$1"
    fi
}

cmd_up() {
    check_deps
    setup_backend

    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    else
        source venv/bin/activate
    fi

    if ! pulumi stack select "$PULUMI_STACK" -c 2>/dev/null; then
        echo "Creating stack $PULUMI_STACK..."
        pulumi stack init "$PULUMI_STACK"
    fi

    # 1. Provision with SSH OPEN
    echo "Step 1/3: Provisioning Server (SSH Open)..."
    pulumi config set sshOpen true
    pulumi up --yes

    IP=$(pulumi stack output instance_ip)
    echo "Server IP: $IP"

    # Ensure key file has correct permissions
    if [ -f "$KEY_FILE" ]; then
        chmod 400 "$KEY_FILE"
    else
        # Try to restore from stack
        pulumi stack output private_key_pem > "$KEY_FILE"
        chmod 400 "$KEY_FILE"
    fi

    echo "Step 2/3: Downloading Configuration..."
    MAX_RETRIES=60
    COUNT=0

    while [ $COUNT -lt $MAX_RETRIES ]; do
        if scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i "$KEY_FILE" "ec2-user@$IP:/home/ec2-user/client.ovpn" "$CONFIG_FILE" 2>/dev/null; then
            echo "Configuration downloaded to $CONFIG_FILE"
            break
        fi

        echo "Waiting for server setup... ($COUNT/$MAX_RETRIES)"
        sleep 5
        COUNT=$((COUNT+1))
    done

    if [ $COUNT -eq $MAX_RETRIES ]; then
        echo "Timeout waiting for VPN configuration."
        exit 1
    fi

    # 2. Lock the Server (SSH CLOSED)
    echo "Step 3/3: Locking Server (Removing SSH Access)..."
    pulumi config set sshOpen false
    pulumi up --yes

    notify "VPN Server is ready and LOCKED! Config saved to $CONFIG_FILE"
}

cmd_down() {
    check_deps
    setup_backend

    if [ ! -d "venv" ]; then
        echo "Creating virtual environment..."
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    else
        source venv/bin/activate
    fi

    # Check if stack exists (it should be imported by CI)
    if ! pulumi stack select "$PULUMI_STACK" -c 2>/dev/null; then
        echo "Error: Stack '$PULUMI_STACK' not found. State restoration might have failed."
        exit 1
    fi

    echo "Destroying infrastructure..."
    pulumi destroy --yes

    rm -f "$CONFIG_FILE" "$KEY_FILE"
    echo "Cleanup complete."
    notify "VPN Server destroyed."
}

cmd_status() {
    check_deps
    setup_backend
    source venv/bin/activate 2>/dev/null || true

    if pulumi stack output instance_ip &>/dev/null; then
        IP=$(pulumi stack output instance_ip)
        echo "VPN Server is active."
        echo "IP: $IP"
        # Check config
        SSH_OPEN=$(pulumi config get sshOpen || echo "true")
        if [ "$SSH_OPEN" = "false" ]; then
            echo "Security: SSH Locked (Secure)"
        else
            echo "Security: SSH Open (Warning)"
        fi
    else
        echo "VPN Server does not appear to be running."
    fi
}

case "$1" in
    up)
        cmd_up
        ;;
    down)
        cmd_down
        ;;
    status)
        cmd_status
        ;;
    *)
        echo "Usage: $0 {up|down|status}"
        exit 1
        ;;
esac
