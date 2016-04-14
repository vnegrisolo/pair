#!/bin/sh

pair() {
  if [ "${1}" == "commit" ]; then
    git $@;
  fi
}
