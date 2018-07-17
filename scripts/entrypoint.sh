#!/bin/sh

set -eu

/usr/local/bin/bridge_init_db.sh

exec /usr/local/bin/bridge -c $BRIDGE_CONFIG_FILE $@
