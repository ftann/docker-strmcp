#!/usr/bin/env bash

set -euo pipefail

. /app/env.sh

: "${SC_CONTROL_DRIVER_HOST?}"
: "${SC_CONTROL_DRIVER_PORT?}"

file_env 'SC_CONTROL_USERNAME'
file_env 'SC_CONTROL_PASSWORD'

export SC_CONTROL_USERNAME SC_CONTROL_PASSWORD

node /app/control.js
tail -f /dev/null
