#!/bin/bash

#
# This Bash script blocks all IP prefixes associated with an ASN (Autonomous System Number).
# An ASN is a unique identifier assigned to a group of IP addresses managed by an autonomous organization.
#
# The script requires the whois command to obtain the IP prefixes associated with the ASN and uses iptables
# and ip6tables to block both IPv4 and IPv6 addresses.
#
# Usage: ./ASN_IPTables_Blocker.sh <ASN>
# Example: ./ASN_IPTables_Blocker.sh 12345
#
# Copyright AGPL License By Marco Marcoaldi for Managed Server Srl - https://managedserver.it
#
#


GREEN='\x1B[32m'
RED='\x1B[31m'
NC='\033[0m' # No Color

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
    echo "Error: command whois not found."
    echo "please install using yum, dnf or apt or similar."
    exit 1
fi


# Name of the script
SCRIPT_NAME="ASN_IPTables_Blocker.sh"

# Function to show the usage syntax
usage() {
    echo "Usage: $SCRIPT_NAME <ASN>"
    echo "Example: $SCRIPT_NAME 12345"
}

# I check if the ASN argument has been passed
if [ $# -ne 1 ]; then
    echo "Error: Wrong Argument number."
    usage
    exit 1
fi

ASN=$1

# Verify that the ASN is a number
if ! [[ $ASN =~ ^[0-9]+$ ]]; then
    echo "Error: Wrong ASN parameter. Only number are accepted without AS prefix."
    usage
    exit 1
fi

# Get the IP prefixes associated with the ASN
PREFIXES=$(whois -h whois.radb.net -- "-i origin AS$ASN" | grep -E '^(route|route6):' | awk '{print $2}')

# Check if IP prefixes have been found
if [ -z "$PREFIXES" ]; then
    echo "No IP prefix found for ASN $ASN."
    exit 1
fi

# Block each IP prefix using iptables and ip6tables
for prefix in $PREFIXES; do
    if [[ $prefix == *":"* ]]; then
        ip6tables -A INPUT -s "$prefix" -j DROP
        echo "IPv6 Blocked $prefix"
    else
        iptables -A INPUT -s "$prefix" -j DROP
        echo "IPv4 Blocked $prefix"
    fi
done

echo "All IP prefixes associated with ASN $ASN have been blocked."
