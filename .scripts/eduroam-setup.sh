#!/bin/bash

# This script is generating an eduroam network configuration using NetworkManager.
# At first, you have to generate an easyroam profile on https://www.easyroam.de/ that
# is generating an pkcs12 file as input for this script.

# Usage:   bash configure-eduroam-with-easyroam.sh <YOUR-PKCS12-File>

set -e

# check for nmcli

if ! type nmcli >/dev/null 2>&1; then
  echo ""
  echo "ERROR: nmcli not found!" >&2
  echo "This wizard assumes that your network connections are managed by NetworkManager." >&2
  echo ""
  exit 1
fi

# check for wifi device

if ! nmcli -g TYPE,DEVICE device | grep wifi >/dev/null; then
  echo ""
  echo "ERROR: Unable to find any wifi device!" >&2
  echo ""
  exit 1
fi

# check input file

if [ -z "$1" ]; then
  echo ""
  echo "Your pkcs12 file is missed as input parameter."
  echo ""
  exit 1
else
  InputFile="$1"
fi

# set openssl legacy options if necessary

LegacyOption=
OpenSSLversion=$(openssl version | awk '{print $2}' | sed -e 's/\..*$//')
if [ "$OpenSSLversion" -eq "3" ]; then
  LegacyOption="-legacy"
fi

# check pkcs12 file

Pwd="pkcs12"

if ! openssl pkcs12 -in "$InputFile" $LegacyOption -info -passin pass: -passout pass:"$Pwd" >/dev/null 2>&1; then
  echo ""
  echo "ERROR: The given input file does not seem to be a valid pkcs12 file."
  echo ""
  exit 1
fi

# configure parameters

WLANName="eduroam"
ConfDir="$HOME/.easyroam"
[ -d "$ConfDir" ] || mkdir -p "$ConfDir"

# extract key, cert, ca and identity

openssl pkcs12 -in "$InputFile" $LegacyOption -nokeys -passin pass: -out "$ConfDir/easyroam_client_cert.pem"
openssl pkcs12 -in "$InputFile" $LegacyOption -nocerts -passin pass: -passout pass:"$Pwd" -out "$ConfDir/easyroam_client_key.pem"
openssl pkcs12 -info -in "$InputFile" $LegacyOption -nokeys -passin pass: -out "$ConfDir/easyroam_root_ca.pem" >/dev/null 2>&1
Identity=$(openssl x509 -noout -in "$ConfDir/easyroam_client_cert.pem" -subject | awk -F \, '{print $1}' | sed -e 's/.*=//' -e 's/\s*//')

# Remove existing connections

nmcli connection show |
  awk '$1==c{ print $2 }' c="$WLANName" |
  xargs -rn1 nmcli connection delete uuid

# Create new connection

nmcli connection add \
  type wifi \
  con-name "$WLANName" \
  ssid "$WLANName" \
  -- \
  wifi-sec.key-mgmt wpa-eap \
  802-1x.eap tls \
  802-1x.identity "$Identity" \
  802-1x.ca-cert "$ConfDir/easyroam_root_ca.pem" \
  802-1x.client-cert "$ConfDir/easyroam_client_cert.pem" \
  802-1x.private-key-password "$Pwd" \
  802-1x.private-key "$ConfDir/easyroam_client_key.pem"
