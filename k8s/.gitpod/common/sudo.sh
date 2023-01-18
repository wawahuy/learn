#!/bin/bash

if [[ "${ETV_CHECK_SUDO}" ]]; then
  return
fi
ETV_CHECK_SUDO=true

SUDO=''
if [[ -e /bin/sudo ]]; then
  echo 'Sudo!'
  SUDO=sudo
fi