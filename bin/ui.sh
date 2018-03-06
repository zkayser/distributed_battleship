#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "usage: `basename $0` commander_ip [--private]"
  exit 2
fi

commander_ip=$1
shift

visibility=public
if [[ $1 == --private || $1 == -p ]]; then
  shift
  visibility=private
fi

elixir --cookie battleships --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --name "ui$$@$commander_ip" -S mix battleship.ui $commander_ip $visibility $@ 

