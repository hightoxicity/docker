#!/bin/bash

for f in `ls /confmgt/confd/conf.d/*.toml`; do
  dest=$(cat $f | grep -P '^\s*dest\s*=\s*"?.+"?\s*$' | sed -r 's/^.+=[[:space:]]*"?([^"]+)"?[[:space:]]*$/\1/g')
  if [ "$?" == "0" ]; then
    dirname=$(dirname ${dest})
    echo "Creating recursively: ${dirname}"
    mkdir -p ${dirname} > /dev/null 2>&1
  fi
done
