#!/bin/bash

echo -e "\033[1mThis is a dedicated script to check whether network configurations were configured as intended (kindly refer to the image of the network topology (assets/topology.PNG).\033[0m"
echo "NOTE: Do ensure that pyATS (pyats[full]) is installed via pip before running the script."
printf "\n\n"

# Create test directory.
mkdir -p pyats/tests


# Parse EIGRP summaries.
genie parse "show ip eigrp interfaces" --testbed-file pyats/testbed.yaml --output pyats/tests/eigrp
genie parse "show ip eigrp neighbors" --testbed-file pyats/testbed.yaml --output pyats/tests/eigrp

# Parse ACL summaries.
genie learn acl --testbed-file pyats/testbed.yaml --output pyats/tests/acl

# Parse interface summaries.
genie parse "show ip interface brief" --testbed-file pyats/testbed.yaml --output pyats/tests/interface

# Parse NAT summaries.
genie parse "show ip nat statistics" --testbed-file pyats/testbed.yaml --output pyats/tests/nat

printf "\n\n"
echo -e "\033[1m+=============================DIFFERENCE CHECK=================================+\033[0m"

# Check for differences in EIGRP on each host with respect to the baseline configuration.
genie diff pyats/baseline/eigrp pyats/tests/eigrp --exclude "srtt" --output pyats/differences

# Check for differences in ACL on each host with respect to the baseline configuration.
genie diff pyats/baseline/acl pyats/tests/acl --exclude "matched_packets" --output pyats/differences

# Check for differences in the interfaces on each host with respect to the baseline configuration.
genie diff pyats/baseline/interface pyats/tests/interface --output pyats/differences

# Check for differences in NAT on each host with respect to the baseline configuration.
genie diff pyats/baseline/nat pyats/tests/nat --exclude "cef_translated_pkts" "dynamic" "extended" "total" "expired_translations" "hits" --output pyats/differences
