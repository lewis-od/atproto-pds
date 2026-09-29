#!/usr/bin/env bash

set -eu

. "$(dirname $0)/.env"

ssh -t "${PDS_USER:-root}@pds.$ROOT_DOMAIN" 'sudo pdsadmin update'
