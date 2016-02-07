#!/bin/bash

set -e

BIN=${BIN:-/bin/bash}

if [ -z "$SERVICES_DATA" ]; then
  SERVICES_DATA='{}'
fi

SERVICES_DATA=${SERVICES_DATA}; /confmgt/bin/attr_merger.sh
export SERVICES_DATA=$(cat /confmgt/attributes.json)

/confmgt/bin/confd -onetime -backend env

echo "We are about to run: $BIN"
exec $BIN
