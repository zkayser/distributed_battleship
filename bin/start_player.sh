# ################################################
# Player
# ###############################################

if [[ $# -ne 2 ]]; then
  echo "usage: `basename $0` commander_ip playername"
  exit 2
fi

commander_ip=$1
player=$2

iex --cookie battleships --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --name $player@$commander_ip -r lib/player/buster.ex -e "Buster.start('$commander_ip', '$player')"

