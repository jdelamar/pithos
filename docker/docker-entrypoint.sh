#!/bin/bash

set -eux

: ${CASSANDRA_SEED='cassandra'}
: ${LOG_LEVEL=info}

cp /pithos/doc/pithos.yaml /etc/pithos/
sed -i \
  -e "s/localhost/${CASSANDRA_SEED}/g" \
  -e "s/level: info/level: ${LOG_LEVEL}/" \
  -e "s/pithos-hostname/${HOSTNAME}/" \
  /etc/pithos/pithos.yaml



readonly version=$(awk '/\(defproject/{gsub("\"", "", $3);print $3}' project.clj)
readonly target="/pithos/pithos-${version}-standalone.jar"

if [[ ! -f "${target}" ]]; then
  lein uberjar
fi

# wait for cassandra being ready
until netcat -z -w 2 ${CASSANDRA_SEED} 9042; do sleep 1; done

java -jar "${target}" -a install-schema || true
exec java -jar "${target}" -a api-run
