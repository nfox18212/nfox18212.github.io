# Pausing

When `sw1` has been hit, the game will go into a blocking loop inside the interrupt after disabling all other interrupts, including the timer.  This will be done using an `eor` instruction and a `beq` instruction.  The board will be replaced with a string that simply says "GAME PAUSED" and this will stay for the duration of the pause.