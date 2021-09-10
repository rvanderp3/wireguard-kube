# Overview

This project enables the WireGuard VPN to be installed on Kubernetes nodes as a daemonset.  WireGuard requires a statically assigned public key and IP address mapping.  One way this project allows the VPN to be deployed as a daemonset is by using the 4th octet as part of the client IP that the WireGuard client uses to communicate with the WireGuard server.  For example:

- WireGuard subnet: `172.16.240.0/20`
- Node IP: `192.168.190.2/20`
- Calculated WireGuard client IP: `172.16.254.2`

Each IP in the `172.16.240.0/20` has a `Peer` definition in the server's WireGuard configuration.  When the daemonset deploys, `entrypoint.sh` calculates the client IP and looks up the associated private key in `/etc/wireguard-profiles/peers` for each node where the daemonset is deployed.  `generate-config.sh` produces a list of private keys as well as configuration to be appended to the end of an existing server WireGuard configuration.

Note: `entrypoint.sh` and `generate-config.sh` will need to be updated to account for your network size and subnet.

# Requirements

- service account with a `privileged` scc
- `wireguard-go` binary compiled for the operating system backing the kubernetes nodes. See: https://github.com/WireGuard/wireguard-go
- Understanding of how to configure `WireGuard`

# Installing

1. Update `entrypoint.sh` as described above
2. Build and push the image containing `wireguard-tools` and `wireguard-go`:
~~~
podman build . --tag=your-registry/your-repo:your-tag
podman push your-registry/your-repo:your-tag
~~~

3. Update `wireguard-ds.yaml` with the image location and the service account with has a `privileged` scc
4. Generate private keys and peer configurations with `generate-config.sh`
5. Update `wireguard-vpn-access.yaml` with the peer private keys: 
    1. Convert the private keys to base64 `cat privkeys | base64 -w0` 
    2. Update the `peers` key/value

5. Update `wireguard-vpn-access.yaml` with the server peer configuration as well as the IP addresses to route via WireGuard: 
    1. Convert the private keys to base64 `cat wg0.conf.tmpl | base64 -w0` 
    2. Update the `wg0.conf.tmpl` key/value

6. Append the content of `wireguard.conf.peers` to the end of the existing WireGuard server configuration
7. Create the resources:
~~~
oc create -f wireguard-vpn-access.yaml -n the-namespace
oc create -f wireguard-ds.yaml -n the-namespace
~~~
