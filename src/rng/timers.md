# Timers

To implement random number generation, we are going to use a seed-based approach.  We will use a seperate timer from the game timer to get a seed value, iterating a memory value at a rate of once per nano second.  This rate may change as we do not want to go over the 32 bit integer limit.  

If this does not give a sufficiently good seed value, we can "mess up" the number more by doing multiple bitwise operations, including a variety of shifts and XORs to make the number more unique.  A second timer may also be used that increments a memory value at a different rate to further alter the number.

These timer(s) will increment until a uart interrupt has occured, which will disable the timer interrupt(s).  To faciliate this, the player will be presented a title screen instead of going directly into the game.  Difficulty options will be presented, and as soon as uart recieves user input, the timers will stop and we will be presented with a seed.
