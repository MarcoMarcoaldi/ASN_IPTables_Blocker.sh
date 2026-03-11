#!/bin/bash

#
# This Bash script blocks all IP prefixes associated with a given ASN (Autonomous System Number).
# An ASN is a globally unique identifier assigned to a network operator (such as an ISP,
# hosting provider, cloud provider, or large organization) that manages one or more IP networks.
#
# The script queries public routing registries via the whois service to retrieve all IPv4 and
# IPv6 prefixes announced by the specified ASN. Once the prefixes are collected, the script
# automatically adds firewall rules using iptables (for IPv4) and ip6tables (for IPv6)
# to drop all incoming traffic originating from those networks.
#
# This can be useful for quickly blocking entire network operators, abusive hosting providers,
# botnet infrastructures, or specific geopolitical regions that are known to generate unwanted
# traffic such as scans, brute-force attempts, or spam.
#
# Requirements:
# - whois command-line utility
# - iptables and ip6tables available on the system
# - root privileges to modify firewall rules
#
# Usage:
# ./ASN_IPTables_Blocker.sh <ASN>
#
# Example:
# ./ASN_IPTables_Blocker.sh 12345
#
# The ASN must be provided as a numeric value without the "AS" prefix.
#
# Copyright AGPL License By Marco Marcoaldi for Managed Server Srl
# https://managedserver.it
#
#


GREEN='\x1B[32m'
RED='\x1B[31m'
NC='\033[0m' # Reset terminal color (No Color)


printf "${GREEN}                                                              \n";
printf "  _____                       _                          _ _   \n";
printf " |     |___ ___ ___ ___ ___ _| |___ ___ ___ _ _ ___ ___ |_| |_ \n";
printf " | | | | .'|   | .'| . | -_| . |_ -| -_|  _| | | -_|  _|| |  _|\n";
printf " |_|_|_|__,|_|_|__,|_  |___|___|___|___|_|  \_/|___|_||_|_|_|  \n";
printf "                   |___|                                        \n${NC}";
printf "\n";
printf " ASN - Autonomous System Number IP Blocker using IPTABLES \n";
printf " _______________________________________________________________\n";
printf "\n";
printf "\n";


if ! command -v whois &> /dev/null
then
    echo "Error: the 'whois' command was not found on this system."
    echo "Please install it using your package manager (yum, dnf, apt, etc.)."
    exit 1
fi


# Script name (used when printing usage instructions)
SCRIPT_NAME="ASN_IPTables_Blocker.sh"

# Function that prints usage instructions for the script
usage() {
    echo "Usage: $SCRIPT_NAME <ASN>"
    echo "Example: $SCRIPT_NAME 12345"
}

# Check whether exactly one argument (the ASN) has been provided
if [ $# -ne 1 ]; then
    echo "Error: invalid number of arguments."
    usage
    exit 1
fi

ASN=$1

# Verify that the ASN parameter contains only numeric characters
# The script expects the ASN without the 'AS' prefix (e.g. 12345 instead of AS12345)
if ! [[ $ASN =~ ^[0-9]+$ ]]; then
    echo "Error: invalid ASN parameter. Only numeric values are accepted without the AS prefix."
    usage
    exit 1
fi

# Retrieve all IP prefixes associated with the specified ASN.
# The query is sent to the RADB whois server which aggregates routing data from multiple registries.
# Both IPv4 (route) and IPv6 (route6) prefixes are extracted from the response.
PREFIXES=$(whois -h whois.radb.net -- "-i origin AS$ASN" | grep -E '^(route|route6):' | awk '{print $2}')

# Verify that at least one IP prefix has been returned
if [ -z "$PREFIXES" ]; then
    echo "No IP prefixes were found for ASN $ASN."
    exit 1
fi

# Iterate through each prefix and apply a firewall rule
# IPv4 networks are blocked using iptables
# IPv6 networks are blocked using ip6tables
for prefix in $PREFIXES; do
    if [[ $prefix == *":"* ]]; then
        ip6tables -A INPUT -s "$prefix" -j DROP
        echo "IPv6 Blocked $prefix"
    else
        iptables -A INPUT -s "$prefix" -j DROP
        echo "IPv4 Blocked $prefix"
    fi
done

# Final confirmation message
echo "All IP prefixes associated with ASN $ASN have been successfully blocked."
