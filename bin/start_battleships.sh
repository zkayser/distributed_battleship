#!/bin/bash
# ###################################################
# Battleshps 
# ###################################################

if=`netstat -f inet -rn | grep default | awk '{ print $6 }'`
ip=`ipconfig getifaddr $if`
echo Listening on $if $ip

# Save IP in clipboard
echo -n $ip | pbcopy

elixir --cookie battleships --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --name commander@$ip -S mix run --no-halt

