#!/bin/bash

if [[ $# -ne 1 ]]; then
  echo "usage: `basename $0` commander_ip"
  exit 2
fi

commander_ip=$1

elixir --cookie battleships --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --name next_phase@$commander_ip -S mix battleship.next_phase $commander_ip

