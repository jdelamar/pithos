#!/bin/bash

set -eux

cp /pithos/doc/pithos.yaml /etc/pithos/
sed -i \
  -e "s/localhost/cassandra/g" \
  -e "s/level: info/level: debug/" \
  /etc/pithos/pithos.yaml

readonly version=$(awk '/\(defproject/{gsub("\"", "", $3);print $3}' project.clj)
readonly target="/pithos/pithos-${version}-standalone.jar"

if [[ ! -f "${target}" ]]; then
  lein uberjar
fi

# wait for cassandra being ready
until netcat -z -w 2 cassandra 9042; do sleep 1; done

java -jar "${target}" -a install-schema
exec java -jar "${target}" -a api-run
