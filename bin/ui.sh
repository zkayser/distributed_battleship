#!/bin/bash

visibility=private
if [[ $1 == --public || $1 == -p ]]; then
  shift
  visibility=public
fi

elixir --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --sname "ui$$" -S mix battleship.ui $visibility $@ 

