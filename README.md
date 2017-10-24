# distributed_battleship

## Summary

A battleship game commander orchestrates the distributed players. Each player is a Node on the erlang network
and can interact with the commander with the following messsages:

* Once the Game Commander is started players wil have 60s to start their player and connect.
* start-game will be cast to all players informing them of the size of the board.
* Each player will send a ship-at message allocating a space on the board for a ship type.
* The commander will inform the players its time to take a turn and the player will return an x,y guess.
* Once all players have taken a turn the commander will cast a feedback message to each player about their individual success.
* Then another turn will be initiated.

## Game Commander Design

Game phases:

* Await players (60 second timer)

Players connect and send in their details.

* Start game

Players are told its time to start with the ocean size, and the number of ship compoents they can use.

* Player ships

Players send in shop location choises,

* Player turns

Each player can take a turn to blow up an opponent.

* Player feedback

Everyone gets feedback on who won the game.

## Program Flow

The game is driven by a sequence of ticks and a predictable period. Every X ticks events can occur.
A game is split into phases represented by states. Ticks initiate a step based on the phase.



