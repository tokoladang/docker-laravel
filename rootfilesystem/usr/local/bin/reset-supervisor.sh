#!/bin/sh

for x in `find /etc/supervisor.d/ -mindepth 1 -type f -name '*.ini' -print`; do mv "$x" "${x%.ini}.disabled"; done
