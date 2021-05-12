#!/usr/bin/bash

CONFIG_FILE_DIR="/etc/wpa_supplicant/my_sh_settings"

connect () {
  sudo /usr/bin/wpa_supplicant -B -i wlo1 -c "${CONFIG_FILE}"
}

create_config_file () {
  local TEMPLATE_FILE
  TEMPLATE_FILE="${CONFIG_FILE_DIR}/template.conf"
  sudo bash -c "
    cat '${TEMPLATE_FILE}' | sed '/^network=/,\$d' > '${CONFIG_FILE}';
    /usr/bin/wpa_passphrase '${SSID}' '${PSK}' | sed '/^[[:space:]]*#/d' >> '${CONFIG_FILE}';
  "
}

error_msg () {
  exec >&2
  echo "error: $1"
  cat <<-_EOF | sed 's#^ *##'
    usage: $(basename $0) <ssid> [<psk>]
	_EOF
}

if [[ -z "$1" ]]; then
  error_msg "invalid argment (ssid not found)"
  exit
fi

SSID="$1"
CONFIG_FILE="${CONFIG_FILE_DIR}/${SSID}.conf"

if [[ ! -f "${CONFIG_FILE}" ]] && [[ -z "$2" ]]; then
  error_msg "invalid argment (psk not found)"
  exit
fi

if [[ -e "${CONFIG_FILE}" ]] && [[ ! -f "${CONFIG_FILE}" ]]; then
  error_msg "config file is already existed, but file type is wrong"
  exit
fi

if [[ ! -f "${CONFIG_FILE}" ]] && [[ ! -z "$2" ]]; then
  PSK="$2"
  create_config_file
fi

connect

