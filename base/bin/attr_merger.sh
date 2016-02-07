#!/bin/bash

echo '{}' > /confmgt/attributes.json
echo '{}' > /confmgt/attributes.merge.json
echo '{}' > /confmgt/attributes.override.json

for f in `ls /confmgt/attributes/ | grep -P '^[0-9]+$' | sort -n`; do
  echo '{}' > /confmgt/attributes/$f/attributes.merge.json
  echo '{}' > /confmgt/attributes/$f/attributes.override.json

  for yaml in `ls /confmgt/attributes/$f/*.yml 2>/dev/null`; do
    cat $yaml | /confmgt/bin/yaml2json > $yaml.json

    cat $yaml.json | /confmgt/bin/jq '.merge' > $yaml.merge.json
    cat $yaml.json | /confmgt/bin/jq '.override' > $yaml.override.json

    if [ "$(cat $yaml.merge.json)" != "null" ]; then
      /confmgt/bin/jq -s '.[0] * .[1]' /confmgt/attributes/$f/attributes.merge.json $yaml.merge.json > /confmgt/attributes/$f/attributes.pivot.merge.json
      mv /confmgt/attributes/$f/attributes.pivot.merge.json /confmgt/attributes/$f/attributes.merge.json
      /confmgt/bin/jq -s '.[0] * .[1]' /confmgt/attributes.merge.json /confmgt/attributes/$f/attributes.merge.json > /confmgt/attributes.pivot.merge.json
      mv /confmgt/attributes.pivot.merge.json /confmgt/attributes.merge.json
    else
      echo '{}' > $yaml.merge.json
    fi

    if [ "$(cat $yaml.override.json)" != "null" ]; then
      /confmgt/bin/jq -s '.[0] + .[1]' /confmgt/attributes/$f/attributes.override.json $yaml.override.json > /confmgt/attributes/$f/attributes.pivot.override.json
      mv /confmgt/attributes/$f/attributes.pivot.override.json /confmgt/attributes/$f/attributes.override.json
      /confmgt/bin/jq -s '.[0] + .[1]' /confmgt/attributes.override.json /confmgt/attributes/$f/attributes.override.json > /confmgt/attributes.pivot.override.json
      mv /confmgt/attributes.pivot.override.json /confmgt/attributes.override.json
    else
      echo '{}' > $yaml.override.json
    fi
  done

  /confmgt/bin/jq -s '.[0] + .[1]' /confmgt/attributes.override.json /confmgt/attributes.merge.json > /confmgt/attributes.json

done

if [ -n "$SERVICES_DATA" ] && [ "$SERVICES_DATA" != "{}" ]; then
  echo "$SERVICES_DATA" | /confmgt/bin/jq '.merge' > /confmgt/attributes.run.merge.json
  echo "$SERVICES_DATA" | /confmgt/bin/jq '.override' > /confmgt/attributes.run.override.json

  if [ "$(cat /confmgt/attributes.run.override.json)" != "null" ]; then
    /confmgt/bin/jq -s '.[0] + .[1]' /confmgt/attributes.json /confmgt/attributes.run.override.json > /confmgt/attributes.run.pivot.override.json
    mv /confmgt/attributes.run.pivot.override.json /confmgt/attributes.json
  fi

  if [ "$(cat /confmgt/attributes.run.merge.json)" != "null" ]; then
    /confmgt/bin/jq -s '.[0] * .[1]' /confmgt/attributes.json /confmgt/attributes.run.merge.json > /confmgt/attributes.run.pivot.merge.json
    mv /confmgt/attributes.run.pivot.merge.json /confmgt/attributes.json
  fi
else
  echo 'No services data provided'
fi

echo "Resulting configuration:"
cat /confmgt/attributes.json
