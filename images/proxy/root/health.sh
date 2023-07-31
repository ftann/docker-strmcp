#!/usr/bin/env bash

set -euo pipefail

wget -q --spider -T 1 http://localhost:8080 || exit 1
