# Distributed Battleship

   DOESN'T WORK YET

## Summary

A battleship game commander orchestrates the distributed players. Each player is a Node on the erlang network
and can interact with the commander with the following messsages:

* Once the Game Commander is started players wil have 60s to start their player and connect.
* start-game will be cast to all players informing them of the size of the board.
* Each player will send a ship-at message allocating a space on the board for a ship type.
* The commander will inform the players its time to take a turn and the player will return an x,y guess.
* Once all players have taken a turn the commander will cast a feedback message to each player about their individual success.
* Then another turn will be initiated.

## Setup

Imaging a room full of eager Elixir programmers wanting to pit their battleships against their opponents. The game progresses like this.

### Introduction

First get over all the firewall issues with are bound to hurt. The game uses erlang clustering which uses the following ports.

* 4369 for primary connections.
* 9000 - 9100 for allocation to each player.

### Play

* Fingers off keyboard please.
* Commander starts a new game.
* Players connect.
* The private UI shows the board as ships are added.
* The public UI shows players names, a cound of the ships they are adding and an empty rippling ocean.
* Commence firing.

## Differences

The rules for normal 2 player battleships work well but some changes are needed to scale to more people.

* If you strike an opponents ship who should know about it? You should, of coarse, but if all players also know it then you can organize into attack groups which if better.
* If you miss should your opponents know? Every guess improves the next players guess, unless there are no turns, just a free flow of bombs launched at random. Then seeing your opponents misses will slow you down, and make the game better.
* When you add ships to a shared ocean, there may already be a ship there. This gives players another way to learn where opponents ships are. Is this fare? Of coarse it is. Track collusions and plan your bombing runs.

## Running

There are a set of scripts that help the distributed game start. First start the server.

  > bin/start_battleships.sh

Then connect up the user interface for the 

## Game Commander Design

Game phases:

* Await players (60 second timer)

Players connect and send in their details.

* Start game

Players are told its time to start with the ocean size, and the number of ship compoents they can use.

* Player ships

Players send in ship location choises.

* Player turns

Each player can take a turn to blow up an opponent.

* Player feedback

Everyone gets feedback on who won the game.

## Program Flow

The game is driven by a sequence of ticks and a predictable period. Every X ticks events can occur.
A game is split into phases represented by states. Ticks initiate a step based on the phase.



