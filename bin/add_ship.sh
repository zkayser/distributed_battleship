#!/bin/bash

if [[ $# -gt 0 ]]; then
  player=$1
else
  echo -n "Enter player name: "
  read player
fi

elixir --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --sname $player -S mix battleship.add_ship $@

