# ################################################
# Player
# ###############################################

player=Buster
if [[ $# -gt 0 ]]; then
  player=$1
fi

iex --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --sname $player -r lib/player/buster.ex -e "Buster.start('$player')"

