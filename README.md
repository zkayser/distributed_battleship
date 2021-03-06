# Distributed Battleship

## Summary

A battleship game orchestrates many players. Each player is a node on the erlang network
and can interact with the commander with the following messsages:

* Once the Game Commander is started players will have some time to start their player and connect.
* All players will be sent a notification that the game is started with the ocean size and the number of ship parts they can allocated.
* Each player will be able to add a set of ship parts to make up a number of ships.
* The commander will inform the players its time to take a turn and the players can submit their guesses as to where their opponents have placed their ships.
* Play containues until there is one player remaining with surviving ships.

## Setup

Imaging a room full of eager Elixir programmers wanting to pit their battleships against their opponents. The game progresses like this.

### Introduction

First get over all the firewall issues which are bound to hurt. The game uses erlang clustering which uses the following ports.

* 4369 for primary connections.
* 9000 - 9100 for allocation to each player.

### Play

* Commander starts a new game.
* Players connect.
* The private UI shows the board as ships are added.
* The public UI shows players names, a count of the ships they are adding and an empty rippling ocean.
* Commence firing.

## Rule Differences

The rules for normal 2 player battleships work well but some changes are needed to scale to more people.

* When you add ships to a shared ocean, there may already be a ship there. This gives players another way to learn where opponents ships are. Is this fare? Of coarse it is. Track collusions and plan your bombing runs.
* If you strike an opponents ship who should know about it? You should, of coarse, but if all players also know it then you can organize into attack groups against a single foe, which is better.
* If you miss should your opponents know? Every guess improves the next players guess, unless there are no turns, just a free flow of bombs launched by your best AI. Then seeing your opponents misses will slow you down, and make the game better.

## Scaling

The game scales as more players register. The ratios are:

* Ocean size:                       number of players * 10 square
* Number of ship parts per player:  ocean size * 0.75

## Running

There are a set of scripts that help the distributed game start. First start the server.

    bin/start_battleships.sh

Then connect up the user interface to see the game progress.

    bin/ui [--private]

## Player API

When the commander starts you will get its IP address. You will need this to connect to the erlang network:

    commander_ip=1.1.1.1

To start your beam you will need to add the erlang networking configutation for this cluster:

    player_name=rose_petal
    iex --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --name $player_name@$commander_ip -r lib/my_player_code.ex -e "MyPlayer.start('$player_name')"

Network connection first, this adds your beam into the same erlang network as the commander.

    Node.connect(:"commander@#{commander_ip}")

How to send message to the commanders services.

    pid = :global.whereis_name(:players)
    GenServer.call(pid, {:register, player_name})

Messages that you will send during the game.

    | Name         | Registry |  Format                                                                                                     |
    |--------------|------------------------------------------------------------------------------------------------------------------------|
    | Register     | :players | {:register, player_name}                                                                                    |
    | Add ships    | :ocean   | {:add_ship, %{player: player_name, from: %{from_x: from_x, from_y: from_y}, to: %{to_x: to_x, to_y: to_y}}} |
    | Take a turn  | :turns   | {:take, player_name, position = %{x: x, y: y}}                                                              |

Messages that you will receive during the game.

    | Name        | Format                                                             |
    |-------------|--------------------------------------------------------------------|
    | Congrats    | {"congratulations", ocean_size, max_ship_parts}                    |
    | Turn Result | {playe_name, position, :hit/:miss}                                 |
    | Winner      | {:game_over, [{winner: player_name}]}                              |

## Game Commander Design

Game phases:

* Await players

Players connect and send in their names.

* Start game

Players are told its time to start with the ocean size, and the number of ship parts they can use.

* Player ships

Players send in ship location choises.

* Player turns

Each player can take a turn to blow up an opponent.

* Player feedback

Everyone gets feedback on who won the game.

## Program Flow

The game is driven by a sequence of ticks and a predictable period. Every X ticks events can occur.
A game is split into phases represented by states. Ticks initiate a step based on the phase.



