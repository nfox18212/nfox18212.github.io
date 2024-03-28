# Movement

The character will move at a rate of two cells per second.  When onto a different face of the cube, the display matrix will pull the adjacent two columns from the new face and display them.  Then, after two game ticks which are half a second have occured, the new face will be fully rendered.

The orientation of the face will be based on the character's orientation, and only the display face's orientation will change.