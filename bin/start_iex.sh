# ################################################
# Player
# ###############################################

if [[ $# -gt 0 ]]; then
  player=$1
else
  echo -n "Enter player name: "
  read player
fi


iex --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --sname $player 
