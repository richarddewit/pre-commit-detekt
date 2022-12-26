#!/bin/bash

set -eux

java -jar "/opt/detekt/detekt-cli-all.jar" "$@"
