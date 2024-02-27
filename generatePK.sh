#!/bin/bash

# Check if the correct number of parameters is provided
if [ $# -ne 3 ]; then
    echo "Usage: $0 <client_id> <local-keystore> <destination-keystore>"
    exit 1
fi

# Assign parameters to variables
client_id=$1
local_keystore=$2
destination_keystore=$3

echo "Creating the client keystore for $client_id"
keytool -genkey -alias $client_id -keyalg RSA -keystore $local_keystore

echo "Converting .jks to PKCS#12\n"
keytool -importkeystore -srckeystore $local_keystore -destkeystore $destination_keystore -deststoretype PKCS12

echo "Exporting the public key from the .p12 keystore.\n"
openssl pkcs12 -in $destination_keystore -nokeys -out pubktest.pem

echo "Export the private key from the .p12 keystore\n"
openssl pkcs12 -in $destination_keystore -nodes -nocerts -out pvtktest.pem

