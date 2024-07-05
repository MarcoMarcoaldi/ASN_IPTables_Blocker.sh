# ASN IP Blocker using IPTABLES

![image](https://github.com/MarcoMarcoaldi/ASN_IPTables_Blocker.sh/assets/113010551/a15d3e45-3bca-4fed-a9ea-11d84f3c8d18)


This Bash script blocks all IP prefixes associated with an ASN (Autonomous System Number). An ASN is a unique identifier assigned to a group of IP addresses managed by an autonomous organization. This can be particularly useful for network administrators and security professionals who need to block traffic from specific networks known for malicious activity.

## Why Block IPs by ASN?

Blocking IP addresses by ASN can be a more efficient way to manage network security. Instead of blocking individual IP addresses or smaller subnets, you can block entire ranges associated with an organization. This is especially useful in situations where you need to mitigate threats from known malicious networks or reduce unwanted traffic from specific regions.

## Features

- Blocks both IPv4 and IPv6 addresses.
- Uses the `whois` command to obtain IP prefixes associated with a given ASN.
- Utilizes `iptables` and `ip6tables` to implement the blocks.

## Requirements

- `whois` command installed
- `iptables` and `ip6tables` installed and configured

## Usage

1. Ensure you have `whois`, `iptables`, and `ip6tables` installed on your system.
2. Clone this repository.
3. Run the script with the ASN you want to block.

### Example

```bash
./ASN_IPTables_Blocker.sh <ASN>
