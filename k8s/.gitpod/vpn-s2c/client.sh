#!/bin/bash
# ref: https://github.com/angristan/openvpn-install/blob/master/openvpn-install.sh
# bash -x /data/vpn-s2c/setup-server.sh
# bash /data/vpn-s2c/setup-server.sh

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $ABSOLUTE_PATH/../common/support-os.sh
source $ABSOLUTE_PATH/../common/sudo.sh

ABSOLUTE_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

while [ $# -gt 0 ]; do
  case "$1" in
    -service) OPENVPN_SERVICE="$2"
    ;;
    *) echo "Invalid option $1" >&2
    exit 1
    ;;
  esac
  shift
  shift
done

function install() {
  if [[ $OS == "ubuntu" ]]; then
    $SUDO apt-get update
    $SUDO apt-get install openvpn psmisc -y
    if [[ ! -e /bin/systemctl ]]; then
      $SUDO apt-get install systemctl -y
    fi
  elif [[ $OS == "centos" ]]; then
    $SUDO yum update -y
    $SUDO yum install epel-release -y
    $SUDO yum install openvpn psmisc -y
    if [[ ! -e /bin/systemctl ]]; then
      $SUDO yum install systemctl -y
    fi
  fi
}

function deploy() {
  echo 'OpenVPN deploy!';
  $SUDO openvpn --config $ABSOLUTE_PATH/node.ovpn
}

function createService() {
  echo 'OpenVPN client service...';

  mkdir -p /etc/easy-tv
  cp $ABSOLUTE_PATH/node.ovpn /etc/easy-tv/node.ovpn

	echo "#!/bin/bash
openvpn --config /etc/easy-tv/node.ovpn" >/etc/easy-tv/openvpn-client.sh

	echo "#!/bin/bash
killall openvpn" >/etc/easy-tv/openvpn-client-kill.sh

  chmod +x /etc/easy-tv/openvpn-client.sh
  chmod +x /etc/easy-tv/openvpn-client-kill.sh

  # Handle the rules via a systemd script
	echo "[Unit]
Description=OpenVPN client
After=network-online.target
Wants=network-online.target
[Service]
ExecStart=/etc/easy-tv/openvpn-client.sh
ExecStop=/etc/easy-tv/openvpn-client-kill.sh
RemainAfterExit=yes
[Install]
WantedBy=multi-user.target" >/etc/systemd/system/easy-tv-openvpn-client.service

  # Enable service and apply rules
	systemctl daemon-reload
	systemctl enable easy-tv-openvpn-client
	systemctl start easy-tv-openvpn-client

  echo 'OpenVPN client service created!'
}

install
if [[ -z "$OPENVPN_SERVICE" ]]; then
  deploy
else
  createService
fi