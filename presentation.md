# Distributed Battleships Design

    https://docs.google.com/presentation/d/1o-rUYDxGzlgnzSBQ-7IiHD1bvtMQ5cSv9gx8qhdbMBQ/edit?usp=sharing

## Slides

### Overiew

Networking was the goal, state was the poblem.

### Rule Differences

The rules for normal 2 player battleships work well but some changes are needed to scale to more people.

* When you add ships to a shared ocean, there may already be a ship there. This gives players another way to learn where opponents ships are. Is this fare? Of coarse it is. Track collusions and plan your bombing runs.
* If you strike an opponents ship who should know about it? You should, of coarse, but if all players also know it then you can organize into attack groups against a single foe, which is better.
* If you miss should your opponents know? Every guess improves the next players guess, unless there are no turns, just a free flow of bombs launched by your best AI. Then seeing your opponents misses will slow you down, and make the game better.


### OO vs Functional

Were is your state?

### What Immutability Doesn't Mean.

* Data does not change.

### Game Flow and Stateful Phases

Ticks drive operations applicable to the current phase.

* Waiting for players
* Adding ships
* Start game
* Taking turns
* Finish

### Battleship Behavior vs Battleshps State

Thought concerns and runtime concerns.

State is in known places.

* Players

  - just players

* Ocean

  - just ocean 

* Turns

  - a turn queue?

* Trigger

  - a semaphor?

Could have:

* Players and Ocean could have just been one giant state process?

  - Would have saved on join problems.
  - Would have avoided data sync between GenServer's.

### Erlang Networks

Connect port and allocation of runtime ports.

Many to many peer network or mesh network.

Performance/scaling.

## The Game

    README: https://github.com/zkayser/distributed_battleship





## References

* Mesh network in erlang: http://learnyousomeerlang.com/distribunomicon
* Through concerns: http://theerlangelist.com/article/spawn_or_not

