# Distributed Battleships Design

## Slides

### Oeriew

Networking was the goal state was the poblem

### OO vs Functional

Were is your state?

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

* Just one giant state.

### Erlang Networks

Connect port and allocation of runtime ports.

Many to many peer network or mesh network.

Performance/scaling.

### 

## References

* Mesh network in erlang: http://learnyousomeerlang.com/distribunomicon
* Through concerns: http://theerlangelist.com/article/spawn_or_not

