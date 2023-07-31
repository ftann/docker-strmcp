#!/usr/bin/env bash

set -euo pipefail

wget -q --spider -T 1 http://localhost:4444/status || exit 1
