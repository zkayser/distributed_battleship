#!/bin/bash

elixir --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --sname player -S mix battleship.ships

