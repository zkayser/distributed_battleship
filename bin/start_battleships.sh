#!/bin/bash
# ###################################################
# Battleshps 
# ###################################################

#--cookie some-cookie-name \
    #--erl '-kernel inet_dist_listen_min <MINPORT>' \
    #--erl '-kernel inet_dist_listen_max <MAXPORT>'

elixir --sname commander -S mix run --no-halt

