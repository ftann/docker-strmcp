#!/usr/bin/env bash

set -euo pipefail

: "${USERNAME?}"
: "${PASSWORD?}"

echo -n "${USERNAME}" > secrets/control_username
echo -n "${PASSWORD}" > secrets/control_password
