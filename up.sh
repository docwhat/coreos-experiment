#!/bin/bash

set -eu

for i in master node1 node2 node3; do
  tmux new-window -c "$PWD" -n "${i} up" vagrant up "$i"
done
