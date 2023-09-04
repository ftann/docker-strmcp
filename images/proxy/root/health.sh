#!/usr/bin/env bash

set -euo pipefail

wget -q --spider -T 1 http://localhost:80 || exit 1
