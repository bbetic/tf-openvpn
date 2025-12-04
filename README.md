# OpenVPN Exclude

`openvpn-exclude` is a utility script designed to help OpenVPN users exclude specific traffic (IP addresses or domains) from being routed through the VPN tunnel. This is useful when you want to access certain services (like banking, local network resources, or bandwidth-heavy sites) using your normal internet connection while keeping the rest of your traffic secure through the VPN.

## Features

-   Exclude specific IP addresses.
-   Exclude specific domains (automatically resolves to IPs).
-   Can be used as a standalone script or as an OpenVPN `route-up` script.

## Usage

### Standalone Mode

You can run the script manually after connecting to the VPN (or before, if you know the gateway remains the same).

```bash
sudo ./openvpn-exclude.sh google.com 8.8.8.8
```

This will add routes for `google.com` (resolved IPs) and `8.8.8.8` to go through your default local gateway.

### OpenVPN Integration

You can configure OpenVPN to run this script automatically when the connection is established.

Add the following to your OpenVPN configuration file (`.ovpn` or `.conf`):

```conf
script-security 2
route-up "/path/to/openvpn-exclude.sh domain1.com domain2.com 1.2.3.4"
```

## Requirements

-   Linux / Unix environment
-   `ip` command (iproute2)
-   `dig` or `host` or `nslookup` (for domain resolution)
-   Root privileges (to modify routing table)

## License

GPLv3
