#!/usr/bin/env bash

set -eu

. "$(dirname $0)/.env"

ssh "root@pds.$ROOT_DOMAIN"
