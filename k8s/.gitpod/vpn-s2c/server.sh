#!/bin/bash
ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $ABSOLUTE_PATH/../common/support-os.sh
source $ABSOLUTE_PATH/../common/sudo.sh

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

dir=$ABSOLUTE_PATH/keys
cd $dir

function installBase() {
  if [[ $OS == "ubuntu" ]]; then
	$SUDO apt-get update
	$SUDO apt-get install git wget iproute2 curl -y
	$SUDO apt-get install systemctl -y
  elif [[ $OS == "centos" ]]; then
	$SUDO yum update -y
	$SUDO yum install git wget iproute curl -y
	if [[ ! -e /bin/systemctl ]]; then
		$SUDO yum install systemctl -y
	fi
  fi
}

function installOpenVPN() {
	if [[ $OS == "ubuntu" ]]; then
		$SUDO apt-get install openvpn -y
	elif [[ $OS == "centos" ]]; then
		$SUDO yum install openvpn -y
	fi


	PORT=1194
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

	# Find out if the machine uses nogroup or nobody for the permissionless group
	if grep -qs "^nogroup:" /etc/group; then
		NOGROUP=nogroup
	else
		NOGROUP=nobody
	fi

	# can gen only copy 
	echo "set_var EASYRSA_CURVE $CERT_CURVE" >>vars
	echo "set_var EASYRSA_ALGO ec" >vars
	SERVER_CN=$(cat SERVER_CN_GENERATED)
	SERVER_NAME=$(cat SERVER_NAME_GENERATED)
	echo "set_var EASYRSA_REQ_CN $SERVER_CN" >>vars

  	# Copy all the generated files
	$SUDO mkdir -p /etc/openvpn/ccd
	$SUDO cp -v $dir/etc/openvpn/* /etc/openvpn
	$SUDO cp -v $dir/etc/openvpn/ccd/* /etc/openvpn/ccd

  	# Make cert revocation list readable for non-root
	$SUDO chmod 644 /etc/openvpn/crl.pem

	# Generate server.conf
	echo "port $PORT" > /etc/openvpn/server.conf
  	echo "proto $PROTOCOL" >> /etc/openvpn/server.conf
	echo "dev tun
user nobody
group $NOGROUP
persist-key
persist-tun
keepalive 10 120
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist ipp.txt" >> /etc/openvpn/server.conf

	# Support multi connect one user
	echo 'duplicate-cn' >> /etc/openvpn/server.conf

	# DNS resolvers
	echo 'push "dhcp-option DNS 8.8.8.8"' >> /etc/openvpn/server.conf
	echo 'push "dhcp-option DNS 8.8.4.4"' >> /etc/openvpn/server.conf

	# echo 'push "redirect-gateway def1 bypass-dhcp"' >>/etc/openvpn/server.conf

	echo "dh none" >>/etc/openvpn/server.conf
	echo "ecdh-curve $DH_CURVE" >>/etc/openvpn/server.conf
	echo "tls-crypt tls-crypt.key" >>/etc/openvpn/server.conf

  	echo "crl-verify crl.pem
ca ca.crt
cert $SERVER_NAME.crt
key $SERVER_NAME.key
auth $HMAC_ALG
cipher $CIPHER
ncp-ciphers $CIPHER
tls-server
tls-version-min 1.2
tls-cipher $CC_CIPHER
client-config-dir /etc/openvpn/ccd
status /var/log/openvpn/status.log
verb 3" >> /etc/openvpn/server.conf

  	# Create client-config-dir dir
	mkdir -p /etc/openvpn/ccd
	# Create log dir
	mkdir -p /var/log/openvpn

  	# Enable routing
	echo 'net.ipv4.ip_forward=1' >/etc/sysctl.d/99-openvpn.conf

  	# Apply sysctl rules
	sysctl --system

  	# Finally, restart and enable OpenVPN
	if [[ $OS == 'centos' ]]; then
		# Don't modify package-provided service
		cp /usr/lib/systemd/system/openvpn-server@.service /etc/systemd/system/openvpn-server@.service
		# Workaround to fix OpenVPN service on OpenVZ
		sed -i 's|LimitNPROC|#LimitNPROC|' /etc/systemd/system/openvpn-server@.service
		# Another workaround to keep using /etc/openvpn/
		sed -i 's|/etc/openvpn/server|/etc/openvpn|' /etc/systemd/system/openvpn-server@.service
		systemctl daemon-reload
		systemctl enable openvpn-server@server
		systemctl restart openvpn-server@server
	elif [[ $OS == "ubuntu" ]] && [[ $VERSION_ID == "16.04" ]]; then
		# On Ubuntu 16.04, we use the package from the OpenVPN repo
		# This package uses a sysvinit service
		systemctl enable openvpn
		systemctl start openvpn
	else
		# Don't modify package-provided service
		cp /lib/systemd/system/openvpn\@.service /etc/systemd/system/openvpn\@.service
		# Workaround to fix OpenVPN service on OpenVZ
		sed -i 's|LimitNPROC|#LimitNPROC|' /etc/systemd/system/openvpn\@.service
		# Another workaround to keep using /etc/openvpn/
		sed -i 's|/etc/openvpn/server|/etc/openvpn|' /etc/systemd/system/openvpn\@.service
		systemctl daemon-reload
		systemctl enable openvpn@server
		systemctl restart openvpn@server
	fi

  	# Add iptables rules in two scripts
	mkdir -p /etc/iptables
	# Script to add rules
	echo "#!/bin/sh
iptables -t nat -I POSTROUTING 1 -s 10.8.0.0/24 -o $NIC -j MASQUERADE
iptables -I INPUT 1 -i tun0 -j ACCEPT
iptables -I FORWARD 1 -i $NIC -o tun0 -j ACCEPT
iptables -I FORWARD 1 -i tun0 -o $NIC -j ACCEPT
iptables -I INPUT 1 -i $NIC -p $PROTOCOL --dport $PORT -j ACCEPT" > /etc/iptables/add-openvpn-rules.sh

	# Script to remove rules
	echo "#!/bin/sh
iptables -t nat -D POSTROUTING -s 10.8.0.0/24 -o $NIC -j MASQUERADE
iptables -D INPUT -i tun0 -j ACCEPT
iptables -D FORWARD -i $NIC -o tun0 -j ACCEPT
iptables -D FORWARD -i tun0 -o $NIC -j ACCEPT
iptables -D INPUT -i $NIC -p $PROTOCOL --dport $PORT -j ACCEPT" >/etc/iptables/rm-openvpn-rules.sh

  	chmod +x /etc/iptables/add-openvpn-rules.sh
	chmod +x /etc/iptables/rm-openvpn-rules.sh

  	# Handle the rules via a systemd script
	echo "[Unit]
Description=iptables rules for OpenVPN
Before=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=/etc/iptables/add-openvpn-rules.sh
ExecStop=/etc/iptables/rm-openvpn-rules.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" >/etc/systemd/system/iptables-openvpn.service

  	# Enable service and apply rules
	systemctl daemon-reload
	systemctl enable iptables-openvpn
	systemctl start iptables-openvpn
}

installBase;
installOpenVPN;