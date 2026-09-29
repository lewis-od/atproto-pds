#!/usr/bin/env bash

set -eu

. "$(dirname $0)/.env"

ssh "${PDS_USER:-root}@pds.$ROOT_DOMAIN"
