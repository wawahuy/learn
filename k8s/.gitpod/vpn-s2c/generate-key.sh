#!/bin/bash

ABSOLUTE_PATH_GK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $ABSOLUTE_PATH_GK/../common/support-os.sh
source $ABSOLUTE_PATH_GK/../common/sudo.sh

ABSOLUTE_PATH_GK="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROTOCOL=tcp
NIC=$(ip -4 route ls | grep default | grep -Po '(?<=dev )(\S+)' | head -1)
CIPHER="AES-128-GCM"  
CERT_TYPE="1" # ECDSA
CERT_CURVE="prime256v1"
CC_CIPHER="TLS-ECDHE-ECDSA-WITH-AES-128-GCM-SHA256"
DH_TYPE="1" # ECDH
DH_CURVE="prime256v1"
HMAC_ALG="SHA256"
TLS_SIG="1" # tls-crypt

dir=$ABSOLUTE_PATH_GK/_keys
dirOutput=$ABSOLUTE_PATH_GK/keys
rm -rf $dir
rm -rf $dirOutput
mkdir -p $dirOutput

function installOpenVPN() {
    # If OpenVPN isn't installed yet, install it. This script is more-or-less
	# idempotent on multiple runs, but will only install OpenVPN from upstream
	# the first time.
	if [[ ! -e /etc/openvpn/server.conf ]]; then
		if [[ $OS == "ubuntu" ]]; then
			$SUDO apt-get update
			$SUDO apt-get -y install ca-certificates gnupg
			# We add the OpenVPN repo to get the latest version.
			if [[ $VERSION_ID == "16.04" ]]; then
				echo "deb http://build.openvpn.net/debian/openvpn/stable xenial main" >/etc/apt/sources.list.d/openvpn.list
				wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add -
				$SUDO apt-get update
			fi
			# Ubuntu > 16.04 and Debian > 8 have OpenVPN >= 2.4 without the need of a third party repository.
			$SUDO apt-get install -y openvpn iptables openssl ca-certificates
		elif [[ $OS == 'centos' ]]; then
			$SUDO yum install -y epel-release
			$SUDO yum install -y openvpn iptables openssl ca-certificates tar 'policycoreutils-python*'
		fi

		# An old version of easy-rsa was available by default in some openvpn packages
		if [[ -d /etc/openvpn/easy-rsa/ ]]; then
			rm -rf /etc/openvpn/easy-rsa/
		fi
  	fi
}

function generateKey() {
    # Install the latest version of easy-rsa from source, if not already installed.
    local version="3.0.7"
    wget -O ~/easy-rsa.tgz https://github.com/OpenVPN/easy-rsa/releases/download/v${version}/EasyRSA-${version}.tgz
    mkdir -p $dir
    tar xzf ~/easy-rsa.tgz --strip-components=1 --directory $dir
    rm -f ~/easy-rsa.tgz
    cd $dir || return
    echo "set_var EASYRSA_ALGO ec" >vars
    echo "set_var EASYRSA_CURVE $CERT_CURVE" >>vars

    # Generate a random, alphanumeric identifier of 16 characters for CN and one for server name
    SERVER_CN="cn_$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
    echo "$SERVER_CN" >SERVER_CN_GENERATED
    echo "$SERVER_CN" >$dirOutput/SERVER_CN_GENERATED
    SERVER_NAME="server_$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)"
    echo "$SERVER_NAME" >SERVER_NAME_GENERATED
    echo "$SERVER_NAME" >$dirOutput/SERVER_NAME_GENERATED
    echo "set_var EASYRSA_REQ_CN $SERVER_CN" >>vars

    # Create the PKI, set up the CA, the DH params and the server certificate
    ./easyrsa init-pki
    ./easyrsa --batch build-ca nopass

    ./easyrsa build-server-full "$SERVER_NAME" nopass
    EASYRSA_CRL_DAYS=3650 ./easyrsa gen-crl
    
    # Generate tls-crypt key
    mkdir -p $dirOutput/etc/openvpn/
    $SUDO openvpn --genkey --secret $dirOutput/etc/openvpn/tls-crypt.key

    # Move all the generated files
	$SUDO cp pki/ca.crt pki/private/ca.key "pki/issued/$SERVER_NAME.crt" "pki/private/$SERVER_NAME.key" $dir/pki/crl.pem $dirOutput/etc/openvpn

  	# Make cert revocation list readable for non-root
	$SUDO chmod 644 $dirOutput/etc/openvpn/crl.pem
}

function newClient() {
	CLIENT=$1
	IP=$2

	# gen ccd
	mkdir -p $dirOutput/etc/openvpn/ccd
	echo "ifconfig-push $IP 255.255.255.0" > $dirOutput/etc/openvpn/ccd/$CLIENT

	# gen ovpn
	cd $dir || return
	./easyrsa build-client-full "$CLIENT" nopass

    output="$dirOutput/$CLIENT.ovpn"
    echo "client" > "$output"
  	echo "proto tcp-client" >> "$output"
	echo "remote 127.0.0.1 1194
dev tun
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
verify-x509-name $SERVER_NAME name
auth $HMAC_ALG
auth-nocache
cipher $CIPHER
tls-client
tls-version-min 1.2
tls-cipher $CC_CIPHER
ignore-unknown-option block-outside-dns
setenv opt block-outside-dns # Prevent Windows 10 DNS leak
verb 3" >> "$output"

	# not redirect traffic
	echo "pull-filter ignore \"redirect-gateway\"" >> "$output"

	# Generates the custom client.ovpn
	{
		echo "<ca>"
		cat "$dir/pki/ca.crt"
		echo "</ca>"
		echo "<cert>"
		awk '/BEGIN/,/END/' "$dir/pki/issued/$CLIENT.crt"
		echo "</cert>"
		echo "<key>"
		cat "$dir/pki/private/$CLIENT.key"
		echo "</key>"
		case $TLS_SIG in
		1)
			echo "<tls-crypt>"
			$SUDO cat $dirOutput/etc/openvpn/tls-crypt.key
			echo "</tls-crypt>"
			;;
		2)
			echo "key-direction 1"
			echo "<tls-auth>"
			$SUDO cat $dirOutput/etc/openvpn/tls-auth.key
			echo "</tls-auth>"
			;;
		esac
	} >>"$output"
	echo "The configuration file has been written to $output"
}

# installOpenVPN
generateKey
newClient master 10.8.0.10
newClient worker1 10.8.0.21
newClient worker2 10.8.0.22
newClient worker3 10.8.0.23
newClient host 10.8.0.100
